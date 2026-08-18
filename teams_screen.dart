import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/player.dart';
import '../models/team.dart';
import '../widgets/network_logo.dart';

class TeamsScreen extends StatelessWidget {
  final List<Team> teams;
  final List<PlayerItem> players;
  const TeamsScreen({super.key, required this.teams, required this.players});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(slivers: [
        const SliverAppBar(pinned: true, backgroundColor: AppColors.background, title: Text('الفرق واللاعبون', style: TextStyle(fontWeight: FontWeight.w900))),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Text('فرق بارزة', style: Theme.of(context).textTheme.titleLarge),
        )),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 9, crossAxisSpacing: 9, childAspectRatio: .92),
            itemCount: teams.take(12).length,
            itemBuilder: (_, i) {
              final t = teams[i];
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  NetworkLogo(url: t.logoUrl, size: 52),
                  const SizedBox(height: 8),
                  Text(t.name, maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
                ]),
              );
            },
          ),
        ),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text('لاعبون بارزون', style: Theme.of(context).textTheme.titleLarge),
        )),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverList.separated(
            itemCount: players.take(10).length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final p = players[i];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColors.border)),
                child: Row(children: [
                  CircleAvatar(radius: 25, backgroundColor: AppColors.surface2, backgroundImage: NetworkImage(p.imageUrl), onBackgroundImageError: (_, __) {}),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 3),
                    Text([p.clubName, p.nationalityName, p.positionName].where((e) => e.isNotEmpty).join(' · '), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.muted, fontSize: 10)),
                  ])),
                  const Icon(Icons.chevron_left_rounded, color: AppColors.muted),
                ]),
              );
            },
          ),
        ),
      ]),
    );
  }
}
