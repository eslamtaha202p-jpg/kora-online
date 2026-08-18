import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/match.dart';
import '../widgets/match_card.dart';
import 'match_details_screen.dart';

class MatchesScreen extends StatelessWidget {
  final List<MatchItem> matches;
  const MatchesScreen({super.key, required this.matches});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(slivers: [
        const SliverAppBar(
          pinned: true,
          backgroundColor: AppColors.background,
          title: Text('المباريات', style: TextStyle(fontWeight: FontWeight.w900)),
          actions: [Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.tune_rounded))],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          sliver: SliverList.separated(
            itemCount: matches.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => MatchCard(
              match: matches[i],
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MatchDetailsScreen(match: matches[i]))),
            ),
          ),
        ),
      ]),
    );
  }
}
