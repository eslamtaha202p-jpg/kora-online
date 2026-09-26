<?php
/**
 * Plugin Name: AppZil E19 One-Shot Bootstrap
 * Description: Temporary staging-only E19 bootstrap. Seeds and verifies the locked 162-owner B2/B4 dataset during activation.
 * Version: 1.0.0
 * Requires PHP: 8.3
 * Author: AppZil
 */

declare(strict_types=1);

if (! defined('ABSPATH')) { exit; }

final class AppZil_E19_One_Shot_Bootstrap {
    private const EXPECTED_TOTAL = 162;
    private const SEED_SHA256 = '846fcbc8b339d852778e4fa5ce2562f7f9e1f034527db849762be3e2dde973ca';
    private const SEED_URL = 'https://dev.appzil.net/wp-content/plugins/appzil-staging-gate-runner/tools/staging-seed/appzil-b2-b4-seed.json';
    private const RESULT_OPTION = 'appzil_e19_oneshot_result';

    public static function activate(): void {
        $result = ['ok' => false, 'generated_at' => gmdate('c'), 'version' => '1.0.0'];
        try {
            $result += self::run();
            $result['ok'] = true;
            update_option(self::RESULT_OPTION, $result, false);
        } catch (Throwable $e) {
            $result['error'] = $e->getMessage();
            update_option(self::RESULT_OPTION, $result, false);
            throw $e;
        }
    }

    private static function run(): array {
        $host = strtolower((string) wp_parse_url(home_url('/'), PHP_URL_HOST));
        if ($host !== 'dev.appzil.net') {
            throw new RuntimeException('Hard block: only dev.appzil.net is allowed.');
        }
        if (wp_get_environment_type() === 'production') {
            throw new RuntimeException('Hard block: production environment detected.');
        }

        $response = wp_remote_get(self::SEED_URL, [
            'timeout' => 20,
            'redirection' => 0,
            'sslverify' => true,
            'headers' => ['Accept' => 'application/json'],
        ]);
        if (is_wp_error($response)) {
            throw new RuntimeException('Seed fetch failed: ' . $response->get_error_message());
        }
        if ((int) wp_remote_retrieve_response_code($response) !== 200) {
            throw new RuntimeException('Seed fetch returned HTTP ' . (int) wp_remote_retrieve_response_code($response));
        }
        $raw = (string) wp_remote_retrieve_body($response);
        if ($raw === '' || ! hash_equals(self::SEED_SHA256, hash('sha256', $raw))) {
            throw new RuntimeException('Seed SHA-256 mismatch.');
        }
        $seed = json_decode($raw, true, 512, JSON_THROW_ON_ERROR);
        if (! is_array($seed) || ! isset($seed['records']) || ! is_array($seed['records'])) {
            throw new RuntimeException('Seed structure is invalid.');
        }
        self::validateSeed($seed['records']);

        global $wpdb;
        if (! ($wpdb instanceof wpdb)) {
            throw new RuntimeException('wpdb unavailable.');
        }
        $dbh = $wpdb->dbh;
        if (! ($dbh instanceof mysqli)) {
            throw new RuntimeException('WordPress DB connection is not mysqli.');
        }

        $owners = $wpdb->prefix . 'az_owners';
        $states = $wpdb->prefix . 'az_object_state';
        self::assertTable($dbh, $owners);
        self::assertTable($dbh, $states);

        self::exec($dbh, 'SET TRANSACTION ISOLATION LEVEL READ COMMITTED');
        self::exec($dbh, 'START TRANSACTION');

        $createdOwners = 0;
        $existingOwners = 0;
        $createdStates = 0;
        $existingStates = 0;
        $approvalRepairs = 0;
        $forcedHold = 0;

        try {
            foreach ($seed['records'] as $row) {
                $ownerId = (string) $row['owner_id'];
                $path = (string) $row['canonical_path'];
                $parent = $row['parent_owner_id'] !== null ? (string) $row['parent_owner_id'] : null;
                $intentCode = $row['intent_code'] !== null ? (string) $row['intent_code'] : null;
                $intentHash = $row['intent_hash'] !== null ? (string) $row['intent_hash'] : null;
                $migration = (string) $row['runtime_seed']['migration_state'];
                $now = gmdate('Y-m-d H:i:s');

                if ($parent !== null && self::fetchOwner($dbh, $owners, $parent) === null) {
                    throw new RuntimeException("Parent {$parent} missing before child {$ownerId}.");
                }

                $before = self::fetchOwner($dbh, $owners, $ownerId);
                $sql = "INSERT INTO `{$owners}` "
                    . "(owner_id,canonical_path,object_kind,object_id,parent_owner_id,intent_code,intent_hash,canonical_approved,migration_state,created_at,updated_at) VALUES ("
                    . self::q($dbh, $ownerId) . ',' . self::q($dbh, $path) . ',NULL,NULL,'
                    . self::qn($dbh, $parent) . ',' . self::qn($dbh, $intentCode) . ',' . self::qn($dbh, $intentHash)
                    . ',1,' . self::q($dbh, $migration) . ',' . self::q($dbh, $now) . ',' . self::q($dbh, $now) . ') '
                    . 'ON DUPLICATE KEY UPDATE owner_id=owner_id';
                self::exec($dbh, $sql);

                $db = self::fetchOwner($dbh, $owners, $ownerId);
                if (! is_array($db)) {
                    $pathOwner = self::fetchOwnerByPath($dbh, $owners, $path);
                    $detail = is_array($pathOwner) ? ('; path belongs to ' . (string) $pathOwner['owner_id']) : '';
                    throw new RuntimeException("Owner {$ownerId} missing after upsert{$detail}.");
                }
                self::assertOwnerMatches($db, $row);
                if ((int) $db['canonical_approved'] !== 1) {
                    self::exec($dbh, "UPDATE `{$owners}` SET canonical_approved=1,updated_at=" . self::q($dbh, $now)
                        . ' WHERE owner_id=' . self::q($dbh, $ownerId));
                    $approvalRepairs++;
                }
                if ($before === null) { $createdOwners++; } else { $existingOwners++; }

                $beforeState = self::fetchState($dbh, $states, $ownerId);
                $stateSql = "INSERT INTO `{$states}` "
                    . "(owner_id,workflow_state,index_state,freshness_state,source_state,last_data_check,last_source_check,last_editorial_review,next_review,freshness_tier,stale_reason,update_priority,last_quality_run_id,state_version,created_at,updated_at) VALUES ("
                    . self::q($dbh, $ownerId)
                    . ",'imported','hold','fresh',NULL,NULL,NULL,NULL,NULL,'STANDARD',NULL,50,NULL,1,"
                    . self::q($dbh, $now) . ',' . self::q($dbh, $now) . ') '
                    . "ON DUPLICATE KEY UPDATE state_version=state_version+IF(index_state<>'hold',1,0),index_state='hold',updated_at=VALUES(updated_at)";
                self::exec($dbh, $stateSql);

                $state = self::fetchState($dbh, $states, $ownerId);
                if (! is_array($state) || (string) $state['index_state'] !== 'hold') {
                    throw new RuntimeException("State hold verification failed for {$ownerId}.");
                }
                if ($beforeState === null) { $createdStates++; }
                else {
                    $existingStates++;
                    if ((string) $beforeState['index_state'] !== 'hold') { $forcedHold++; }
                }
            }

            $verify = self::verify($dbh, $owners, $states, $seed['records']);
            if (! $verify['pass']) {
                throw new RuntimeException('Post-seed verification failed: ' . implode('; ', $verify['errors']));
            }
            self::exec($dbh, 'COMMIT');
        } catch (Throwable $e) {
            @mysqli_query($dbh, 'ROLLBACK');
            throw $e;
        }

        if (function_exists('wp_cache_flush')) { wp_cache_flush(); }

        return [
            'seed_sha256' => self::SEED_SHA256,
            'write' => [
                'created_owners' => $createdOwners,
                'existing_owners' => $existingOwners,
                'created_states' => $createdStates,
                'existing_states' => $existingStates,
                'canonical_approval_repairs' => $approvalRepairs,
                'forced_hold' => $forcedHold,
            ],
            'verify' => $verify,
        ];
    }

    private static function validateSeed(array $records): void {
        if (count($records) !== self::EXPECTED_TOTAL) {
            throw new RuntimeException('Seed must contain exactly 162 records.');
        }
        $ids = [];
        $paths = [];
        $hold = 0;
        $classes = [];
        foreach ($records as $row) {
            $id = (string) ($row['owner_id'] ?? '');
            $path = (string) ($row['canonical_path'] ?? '');
            if ($id === '' || isset($ids[$id])) { throw new RuntimeException('Duplicate/empty owner_id: ' . $id); }
            if ($path === '' || isset($paths[$path])) { throw new RuntimeException('Duplicate/empty canonical_path: ' . $path); }
            $ids[$id] = true;
            $paths[$path] = true;
            if (($row['runtime_seed']['index_state'] ?? null) === 'hold') { $hold++; }
            $class = (string) ($row['b4']['url_class'] ?? '');
            $classes[$class] = ($classes[$class] ?? 0) + 1;
        }
        $expected = ['ACTIVE_OWNER' => 9, 'GATED_OWNER' => 122, 'CONDITIONAL_OWNER' => 19, 'LEGACY_OWNER' => 12];
        foreach ($expected as $class => $count) {
            if (($classes[$class] ?? 0) !== $count) { throw new RuntimeException("{$class} count mismatch."); }
        }
        if ($hold !== self::EXPECTED_TOTAL) { throw new RuntimeException('All records must start on hold.'); }
    }

    private static function verify(mysqli $dbh, string $owners, string $states, array $records): array {
        $errors = [];
        $ids = array_map(static fn(array $r): string => (string) $r['owner_id'], $records);
        $in = implode(',', array_map(static fn(string $v): string => self::q($dbh, $v), $ids));

        $ownerCount = self::scalarInt($dbh, "SELECT COUNT(*) FROM `{$owners}` WHERE owner_id IN ({$in})");
        $stateCount = self::scalarInt($dbh, "SELECT COUNT(*) FROM `{$states}` WHERE owner_id IN ({$in})");
        $hold = self::scalarInt($dbh, "SELECT COUNT(*) FROM `{$states}` WHERE owner_id IN ({$in}) AND index_state='hold'");
        $indexable = self::scalarInt($dbh, "SELECT COUNT(*) FROM `{$states}` WHERE owner_id IN ({$in}) AND index_state='indexable'");
        $approved = self::scalarInt($dbh, "SELECT COUNT(*) FROM `{$owners}` WHERE owner_id IN ({$in}) AND canonical_approved=1");
        $legacy = self::scalarInt($dbh, "SELECT COUNT(*) FROM `{$owners}` WHERE owner_id IN ({$in}) AND migration_state='preserve_legacy'");
        $orphans = self::scalarInt($dbh, "SELECT COUNT(*) FROM `{$owners}` c LEFT JOIN `{$owners}` p ON p.owner_id=c.parent_owner_id WHERE c.owner_id IN ({$in}) AND c.parent_owner_id IS NOT NULL AND p.owner_id IS NULL");
        $dupes = self::scalarInt($dbh, "SELECT COUNT(*) FROM (SELECT canonical_path FROM `{$owners}` WHERE owner_id IN ({$in}) GROUP BY canonical_path HAVING COUNT(*)>1) d");

        if ($ownerCount !== 162) $errors[] = "owners={$ownerCount}";
        if ($stateCount !== 162) $errors[] = "states={$stateCount}";
        if ($hold !== 162) $errors[] = "hold={$hold}";
        if ($indexable !== 0) $errors[] = "indexable={$indexable}";
        if ($approved !== 162) $errors[] = "approved={$approved}";
        if ($legacy !== 12) $errors[] = "legacy={$legacy}";
        if ($orphans !== 0) $errors[] = "orphans={$orphans}";
        if ($dupes !== 0) $errors[] = "duplicate_paths={$dupes}";

        foreach ($records as $row) {
            $db = self::fetchOwner($dbh, $owners, (string) $row['owner_id']);
            if (! is_array($db)) {
                $errors[] = (string) $row['owner_id'] . ':missing';
                continue;
            }
            try { self::assertOwnerMatches($db, $row); }
            catch (Throwable $e) { $errors[] = (string) $row['owner_id'] . ':' . $e->getMessage(); }
        }

        return [
            'pass' => $errors === [],
            'owners' => $ownerCount,
            'states' => $stateCount,
            'hold' => $hold,
            'indexable' => $indexable,
            'canonical_approved' => $approved,
            'legacy_preserved' => $legacy,
            'orphan_parents' => $orphans,
            'duplicate_paths' => $dupes,
            'errors' => $errors,
        ];
    }

    private static function assertOwnerMatches(array $db, array $row): void {
        $pairs = [
            'canonical_path' => (string) $row['canonical_path'],
            'parent_owner_id' => $row['parent_owner_id'] !== null ? (string) $row['parent_owner_id'] : null,
            'intent_code' => $row['intent_code'] !== null ? (string) $row['intent_code'] : null,
            'intent_hash' => $row['intent_hash'] !== null ? (string) $row['intent_hash'] : null,
            'migration_state' => (string) $row['runtime_seed']['migration_state'],
        ];
        foreach ($pairs as $key => $expected) {
            $actual = array_key_exists($key, $db) && $db[$key] !== null ? (string) $db[$key] : null;
            if ($actual !== $expected) { throw new RuntimeException("{$key} mismatch"); }
        }
    }

    private static function assertTable(mysqli $dbh, string $table): void {
        $res = mysqli_query($dbh, 'SHOW TABLES LIKE ' . self::q($dbh, $table));
        if ($res === false || mysqli_num_rows($res) !== 1) {
            throw new RuntimeException('Required table missing: ' . $table);
        }
        mysqli_free_result($res);
    }

    private static function fetchOwner(mysqli $dbh, string $table, string $id): ?array {
        return self::fetchOne($dbh, "SELECT owner_id,canonical_path,parent_owner_id,intent_code,intent_hash,canonical_approved,migration_state FROM `{$table}` WHERE owner_id=" . self::q($dbh, $id) . ' LIMIT 1');
    }

    private static function fetchOwnerByPath(mysqli $dbh, string $table, string $path): ?array {
        return self::fetchOne($dbh, "SELECT owner_id,canonical_path,parent_owner_id,intent_code,intent_hash,canonical_approved,migration_state FROM `{$table}` WHERE canonical_path=" . self::q($dbh, $path) . ' LIMIT 1');
    }

    private static function fetchState(mysqli $dbh, string $table, string $id): ?array {
        return self::fetchOne($dbh, "SELECT owner_id,index_state,state_version FROM `{$table}` WHERE owner_id=" . self::q($dbh, $id) . ' LIMIT 1');
    }

    private static function fetchOne(mysqli $dbh, string $sql): ?array {
        $res = mysqli_query($dbh, $sql);
        if ($res === false) { throw new RuntimeException('MariaDB [' . mysqli_errno($dbh) . '] ' . mysqli_error($dbh)); }
        $row = mysqli_fetch_assoc($res);
        mysqli_free_result($res);
        return is_array($row) ? $row : null;
    }

    private static function scalarInt(mysqli $dbh, string $sql): int {
        $res = mysqli_query($dbh, $sql);
        if ($res === false) { throw new RuntimeException('MariaDB [' . mysqli_errno($dbh) . '] ' . mysqli_error($dbh)); }
        $row = mysqli_fetch_row($res);
        mysqli_free_result($res);
        return (int) ($row[0] ?? 0);
    }

    private static function exec(mysqli $dbh, string $sql): void {
        $r = mysqli_query($dbh, $sql);
        if ($r === false) { throw new RuntimeException('MariaDB [' . mysqli_errno($dbh) . '] ' . mysqli_error($dbh)); }
        if ($r instanceof mysqli_result) { mysqli_free_result($r); }
    }

    private static function q(mysqli $dbh, string $value): string {
        return "'" . mysqli_real_escape_string($dbh, $value) . "'";
    }

    private static function qn(mysqli $dbh, ?string $value): string {
        return $value === null ? 'NULL' : self::q($dbh, $value);
    }
}

register_activation_hook(__FILE__, [AppZil_E19_One_Shot_Bootstrap::class, 'activate']);
