import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/scorer.dart';

class ScorersScreen extends StatelessWidget {
  final List<ScorerItem> scorers;
  const ScorersScreen({super.key, required this.scorers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: AppColors.background, title: const Text('الهدافون', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: scorers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final s = scorers[i];
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColors.border)),
            child: Row(children: [
              SizedBox(width: 34, child: Text('${i + 1}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: i < 3 ? AppColors.accent : AppColors.muted))),
              CircleAvatar(backgroundColor: AppColors.surface2, child: Text(s.shortName.isEmpty ? '?' : s.shortName.substring(0, 1))),
              const SizedBox(width: 11),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(s.secondary, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.muted, fontSize: 10)),
              ])),
              Text('${s.value}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary)),
            ]),
          );
        },
      ),
    );
  }
}
