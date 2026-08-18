import 'package:flutter/material.dart';

import '../core/app_theme.dart';

class NetworkLogo extends StatelessWidget {
  final String url;
  final double size;
  final IconData fallbackIcon;

  const NetworkLogo({
    super.key,
    required this.url,
    this.size = 48,
    this.fallbackIcon = Icons.shield_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * .08),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(size * .24),
        border: Border.all(color: AppColors.border),
      ),
      child: Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(fallbackIcon, color: AppColors.primary, size: size * .6),
      ),
    );
  }
}
