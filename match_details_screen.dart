import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/match.dart';
import '../widgets/network_logo.dart';

class MatchDetailsScreen extends StatelessWidget {
  final MatchItem match;
  const MatchDetailsScreen({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('تفاصيل المباراة', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.star_border_rounded))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF12355C), Color(0xFF0B182A)]),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFF215E91)),
            ),
            child: Column(children: [
              Text(match.competitionName, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)),
              if (match.stageName.isNotEmpty) Text(match.stageName, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
              const SizedBox(height: 22),
              Row(children: [
                Expanded(child: _Team(teamName: match.home.name, logo: match.home.logoUrl)),
                Column(children: [
                  if ((match.home.score ?? -1) >= 0 && (match.away.score ?? -1) >= 0)
                    Text('${match.home.score} - ${match.away.score}', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900))
                  else
                    Text(match.kickoffLabel, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5),
                  Text(match.statusText, style: TextStyle(color: match.isLive ? AppColors.success : AppColors.muted)),
                ]),
                Expanded(child: _Team(teamName: match.away.name, logo: match.away.logoUrl)),
              ]),
              if (match.venueName.isNotEmpty) ...[
                const SizedBox(height: 18),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.stadium_outlined, color: AppColors.muted, size: 16),
                  const SizedBox(width: 5),
                  Flexible(child: Text(match.venueName, style: const TextStyle(color: AppColors.muted, fontSize: 11))),
                ]),
              ],
            ]),
          ),
          const SizedBox(height: 16),
          _FeatureGrid(match: match),
          const SizedBox(height: 18),
          const _PendingEndpointCard(
            icon: Icons.timeline_rounded,
            title: 'الأحداث لحظة بلحظة',
            subtitle: 'الواجهة جاهزة. هنربطها أول ما نلتقط Endpoint أحداث المباراة.',
          ),
          const SizedBox(height: 10),
          const _PendingEndpointCard(
            icon: Icons.grid_view_rounded,
            title: 'التشكيل والإحصائيات',
            subtitle: 'هنا هتظهر التشكيلة، التسديدات، الاستحواذ وباقي الإحصائيات بعد ربط مسارات Game Details.',
          ),
        ],
      ),
    );
  }
}

class _Team extends StatelessWidget {
  final String teamName;
  final String logo;
  const _Team({required this.teamName, required this.logo});
  @override
  Widget build(BuildContext context) => Column(children: [
    NetworkLogo(url: logo, size: 68),
    const SizedBox(height: 9),
    Text(teamName, maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
  ]);
}

class _FeatureGrid extends StatelessWidget {
  final MatchItem match;
  const _FeatureGrid({required this.match});
  @override
  Widget build(BuildContext context) {
    final items = [
      ('التشكيل', match.hasLineups, Icons.groups_2_outlined),
      ('الإحصائيات', match.hasStats, Icons.bar_chart_rounded),
      ('الترتيب', match.hasStandings, Icons.emoji_events_outlined),
      ('القنوات', match.hasTvNetworks, Icons.tv_outlined),
    ];
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: items.map((e) => Container(
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(e.$3, color: e.$2 ? AppColors.primary : AppColors.muted),
          const SizedBox(height: 5),
          Text(e.$1, style: TextStyle(fontSize: 10, color: e.$2 ? AppColors.text : AppColors.muted, fontWeight: FontWeight.w700)),
        ]),
      )).toList(),
    );
  }
}

class _PendingEndpointCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _PendingEndpointCard({required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
    child: Row(children: [
      Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: AppColors.accent)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 11, height: 1.5)),
      ])),
    ]),
  );
}
