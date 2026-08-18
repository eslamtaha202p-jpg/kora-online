import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/competition.dart';
import '../widgets/network_logo.dart';

class StandingsScreen extends StatelessWidget {
  final Competition competition;
  const StandingsScreen({super.key, required this.competition});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: AppColors.background, title: const Text('ترتيب الدوري', style: TextStyle(fontWeight: FontWeight.w900))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
            child: Row(children: [
              NetworkLogo(url: competition.logoUrl, size: 54, fallbackIcon: Icons.emoji_events_outlined),
              const SizedBox(width: 12),
              Expanded(child: Text(competition.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
            ]),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
              child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.leaderboard_rounded, color: AppColors.primary, size: 48),
                SizedBox(height: 12),
                Text('واجهة الترتيب جاهزة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                SizedBox(height: 7),
                Text('أول ما نلتقط JSON الخاص بالـStandings هنربطه هنا مباشرة من غير تغيير تصميم الشاشة.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted, height: 1.6)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
