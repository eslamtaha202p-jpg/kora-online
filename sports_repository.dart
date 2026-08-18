import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../models/competition.dart';
import '../models/match.dart';
import '../models/player.dart';
import '../models/scorer.dart';
import '../models/team.dart';

class RepositorySnapshot {
  final List<MatchItem> currentMatches;
  final List<MatchItem> featuredMatches;
  final List<Competition> competitions;
  final List<ScorerItem> scorers;
  final List<Team> teams;
  final List<PlayerItem> players;
  final bool usedFallback;
  final String? warning;

  const RepositorySnapshot({
    required this.currentMatches,
    required this.featuredMatches,
    required this.competitions,
    required this.scorers,
    required this.teams,
    required this.players,
    required this.usedFallback,
    this.warning,
  });
}

class SportsRepository {
  final http.Client _client;

  SportsRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<RepositorySnapshot> loadDashboard({int competitionId = 572, int statsCompetitionId = 332}) async {
    var fallback = false;
    String? warning;

    Future<Map<String, dynamic>> safe(
      String path,
      Map<String, String> params,
      String asset,
    ) async {
      try {
        final response = await _client.get(ApiConfig.uri(path, params)).timeout(const Duration(seconds: 8));
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw Exception('HTTP ${response.statusCode}');
        }
        return _decode(response.body);
      } catch (e) {
        fallback = true;
        warning ??= 'يتم عرض Snapshot محلي لأن المصدر الحي لم يستجب: $e';
        return _loadAsset(asset);
      }
    }

    final responses = await Future.wait([
      safe('/web/games/current/', {
        'competitions': '$competitionId',
        'showOdds': 'false',
        'includeTopBettingOpportunity': '0',
      }, 'assets/mock/games_current.json'),
      safe('/web/games/featured/', {
        'competitions': '$competitionId',
        'sports': '',
        'showOdds': 'false',
        'context': '3',
      }, 'assets/mock/games_featured.json'),
      safe('/web/stats/', {
        'competitions': '$statsCompetitionId',
        'competitors': '',
        'withSeasons': 'true',
      }, 'assets/mock/stats.json'),
      safe('/web/competitions/top/', {'limit': '12'}, 'assets/mock/competitions_top.json'),
      safe('/web/competitors/top/', {'limit': '12'}, 'assets/mock/competitors_top.json'),
      safe('/web/athletes/top/', {'limit': '10'}, 'assets/mock/athletes_top.json'),
    ]);

    return RepositorySnapshot(
      currentMatches: _matches(responses[0]),
      featuredMatches: _matches(responses[1]),
      scorers: _scorers(responses[2]),
      competitions: _competitions(responses[3]),
      teams: _teams(responses[4]),
      players: _players(responses[5]),
      usedFallback: fallback,
      warning: warning,
    );
  }

  Future<Map<String, dynamic>> _loadAsset(String path) async {
    final text = await rootBundle.loadString(path);
    return _decode(text);
  }

  Map<String, dynamic> _decode(String text) {
    final decoded = jsonDecode(text);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return decoded.map((k, v) => MapEntry('$k', v));
    return <String, dynamic>{};
  }

  List<MatchItem> _matches(Map<String, dynamic> json) => _list(json['games'])
      .map((e) => MatchItem.fromJson(e))
      .toList(growable: false);

  List<Competition> _competitions(Map<String, dynamic> json) => _list(json['competitions'])
      .map((e) => Competition.fromJson(e))
      .toList(growable: false);

  List<Team> _teams(Map<String, dynamic> json) => _list(json['competitors'])
      .map((e) => Team.fromJson(e))
      .toList(growable: false);

  List<PlayerItem> _players(Map<String, dynamic> json) => _list(json['athletes'])
      .map((e) => PlayerItem.fromJson(e))
      .toList(growable: false);

  List<ScorerItem> _scorers(Map<String, dynamic> json) {
    final stats = json['stats'] is Map ? Map<String, dynamic>.from(json['stats']) : const <String, dynamic>{};
    final blocks = _list(stats['athletesStats']);
    if (blocks.isEmpty) return const [];
    final goalsBlock = blocks.cast<Map<String, dynamic>>().firstWhere(
          (block) => (block['name'] ?? '').toString().contains('الأهداف'),
          orElse: () => blocks.first,
        );
    return _list(goalsBlock['rows']).take(10).map(ScorerItem.fromRow).toList(growable: false);
  }

  List<Map<String, dynamic>> _list(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  void dispose() => _client.close();
}
