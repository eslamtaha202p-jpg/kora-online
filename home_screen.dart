import 'package:flutter/material.dart';

import '../core/app_identity.dart';
import '../core/app_theme.dart';
import '../data/sports_repository.dart';
import '../widgets/match_card.dart';
import '../widgets/network_logo.dart';
import '../widgets/section_header.dart';
import 'match_details_screen.dart';
import 'scorers_screen.dart';

class HomeScreen extends StatelessWidget {
  final RepositorySnapshot snapshot;
  final Future<void> Function() onRefresh;

  const HomeScreen({super.key, required this.snapshot, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final featured = snapshot.featuredMatches.isNotEmpty
        ? snapshot.featuredMatches.first
        : (snapshot.currentMatches.isNotEmpty ? snapshot.currentMatches.first : null);

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: onRefresh,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _TopBar(usingFallback: snapshot.usedFallback)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.list(children: [
                const SizedBox(height: 8),
                _FilterPills(matchCount: snapshot.currentMatches.length),
                if (featured != null) ...[
                  const SectionHeader(title: 'المباراة الأبرز'),
                  MatchCard(
                    match: featured,
                    featured: true,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MatchDetailsScreen(match: featured))),
                  ),
                ],
                SectionHeader(title: 'مباريات اليوم', action: 'عرض الكل', onTap: () {}),
                ...snapshot.currentMatches.take(5).map((match) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: MatchCard(match: match, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MatchDetailsScreen(match: match)))),
                )),
                SectionHeader(
                  title: 'الهدافون',
                  action: 'عرض الكل',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ScorersScreen(scorers: snapshot.scorers))),
                ),
                _ScorersStrip(snapshot: snapshot),
                const SectionHeader(title: 'بطولات مهمة'),
                _CompetitionStrip(snapshot: snapshot),
                const SizedBox(height: 28),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool usingFallback;
  const _TopBar({required this.usingFallback});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primaryDeep, AppColors.primary]),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.sports_soccer, color: Colors.white),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(AppIdentity.brandName, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
              Text(AppIdentity.tagline, style: TextStyle(color: AppColors.muted, fontSize: 11)),
            ]),
          ),
          if (usingFallback)
            const Tooltip(message: 'Snapshot محلي', child: Icon(Icons.offline_bolt_outlined, color: AppColors.accent)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
        ],
      ),
    );
  }
}

class _FilterPills extends StatelessWidget {
  final int matchCount;
  const _FilterPills({required this.matchCount});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _pill('الكل', true),
          _pill('اليوم · $matchCount', false),
          _pill('مباشر', false),
          _pill('غدًا', false),
          _pill('مفضلة', false),
        ],
      ),
    );
  }

  Widget _pill(String label, bool active) => Container(
    margin: const EdgeInsets.only(left: 8),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: active ? AppColors.primaryDeep : AppColors.surface,
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: active ? AppColors.primaryDeep : AppColors.border),
    ),
    child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: active ? Colors.white : AppColors.muted)),
  );
}

class _ScorersStrip extends StatelessWidget {
  final RepositorySnapshot snapshot;
  const _ScorersStrip({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    if (snapshot.scorers.isEmpty) return const _EmptyBlock(text: 'لم تصل بيانات الهدافين بعد');
    return SizedBox(
      height: 142,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: snapshot.scorers.take(6).length,
        separatorBuilder: (_, __) => const SizedBox(width: 9),
        itemBuilder: (_, i) {
          final s = snapshot.scorers[i];
          return Container(
            width: 125,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                CircleAvatar(radius: 18, backgroundColor: AppColors.surface2, child: Text('${i + 1}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900))),
                const Spacer(),
                Text('${s.value}', style: const TextStyle(fontSize: 20, color: AppColors.accent, fontWeight: FontWeight.w900)),
              ]),
              const Spacer(),
              Text(s.shortName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(s.secondary, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.muted, fontSize: 9)),
            ]),
          );
        },
      ),
    );
  }
}

class _CompetitionStrip extends StatelessWidget {
  final RepositorySnapshot snapshot;
  const _CompetitionStrip({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    if (snapshot.competitions.isEmpty) return const _EmptyBlock(text: 'لم تصل بيانات البطولات بعد');
    return SizedBox(
      height: 114,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: snapshot.competitions.take(8).length,
        separatorBuilder: (_, __) => const SizedBox(width: 9),
        itemBuilder: (_, i) {
          final c = snapshot.competitions[i];
          return Container(
            width: 112,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
            child: Column(children: [
              NetworkLogo(url: c.logoUrl, size: 46, fallbackIcon: Icons.emoji_events_outlined),
              const SizedBox(height: 7),
              Text(c.name, maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
            ]),
          );
        },
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  final String text;
  const _EmptyBlock({required this.text});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
    child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
  );
}
