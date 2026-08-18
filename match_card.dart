import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/match.dart';
import 'network_logo.dart';

class MatchCard extends StatelessWidget {
  final MatchItem match;
  final VoidCallback? onTap;
  final bool featured;

  const MatchCard({super.key, required this.match, this.onTap, this.featured = false});

  @override
  Widget build(BuildContext context) {
    final live = match.isLive;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: featured
              ? const LinearGradient(
                  colors: [Color(0xFF102D50), Color(0xFF0B182A)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                )
              : null,
          color: featured ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: featured ? const Color(0xFF195F90) : AppColors.border),
          boxShadow: featured ? const [BoxShadow(color: Color(0x3314B8FF), blurRadius: 22)] : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    match.competitionName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
                if (live)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: .15), borderRadius: BorderRadius.circular(99)),
                    child: const Text('مباشر', style: TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.w800)),
                  ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: _TeamSide(teamName: match.home.name, logo: match.home.logoUrl)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      if ((match.home.score ?? -1) >= 0 && (match.away.score ?? -1) >= 0)
                        Text('${match.home.score}  -  ${match.away.score}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900))
                      else
                        Text(match.kickoffLabel, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text(live ? match.gameTimeDisplay : match.statusText, style: TextStyle(color: live ? AppColors.success : AppColors.muted, fontSize: 11)),
                    ],
                  ),
                ),
                Expanded(child: _TeamSide(teamName: match.away.name, logo: match.away.logoUrl)),
              ],
            ),
            if (featured && match.venueName.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.stadium_outlined, size: 15, color: AppColors.muted),
                  const SizedBox(width: 5),
                  Flexible(child: Text(match.venueName, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.muted, fontSize: 11))),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TeamSide extends StatelessWidget {
  final String teamName;
  final String logo;

  const _TeamSide({required this.teamName, required this.logo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NetworkLogo(url: logo, size: 50),
        const SizedBox(height: 8),
        Text(teamName, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
      ],
    );
  }
}
