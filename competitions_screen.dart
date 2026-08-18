import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/competition.dart';
import '../models/scorer.dart';
import '../widgets/network_logo.dart';
import 'scorers_screen.dart';
import 'standings_screen.dart';

class CompetitionsScreen extends StatelessWidget {
  final List<Competition> competitions;
  final List<ScorerItem> scorers;
  const CompetitionsScreen({super.key, required this.competitions, required this.scorers});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(slivers: [
        const SliverAppBar(pinned: true, backgroundColor: AppColors.background, title: Text('البطولات', style: TextStyle(fontWeight: FontWeight.w900))),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.5),
            itemCount: competitions.length,
            itemBuilder: (_, i) {
              final c = competitions[i];
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _openCompetition(context, c),
                child: Ink(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                  child: Row(children: [
                    NetworkLogo(url: c.logoUrl, size: 50, fallbackIcon: Icons.emoji_events_outlined),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(c.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 5),
                      Text(c.hasStandings ? 'ترتيب متاح' : c.hasBrackets ? 'نظام إقصائي' : 'بطولة', style: const TextStyle(color: AppColors.muted, fontSize: 9)),
                    ])),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  void _openCompetition(BuildContext context, Competition c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              NetworkLogo(url: c.logoUrl, size: 54, fallbackIcon: Icons.emoji_events_outlined),
              const SizedBox(width: 12),
              Expanded(child: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17))),
            ]),
            const SizedBox(height: 14),
            ListTile(
              leading: const Icon(Icons.leaderboard_outlined, color: AppColors.primary),
              title: const Text('ترتيب الدوري'),
              subtitle: const Text('واجهة جاهزة للربط بالـEndpoint القادم'),
              onTap: () { Navigator.pop(ctx); Navigator.of(context).push(MaterialPageRoute(builder: (_) => StandingsScreen(competition: c))); },
            ),
            ListTile(
              leading: const Icon(Icons.sports_soccer, color: AppColors.accent),
              title: const Text('الهدافون'),
              onTap: () { Navigator.pop(ctx); Navigator.of(context).push(MaterialPageRoute(builder: (_) => ScorersScreen(scorers: scorers))); },
            ),
          ]),
        ),
      ),
    );
  }
}
