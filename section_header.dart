import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onTap;

  const SectionHeader({super.key, required this.title, this.action, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
      child: Row(
        children: [
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
          if (action != null)
            TextButton(
              onPressed: onTap,
              child: Text(action!, style: const TextStyle(color: AppColors.primary)),
            ),
        ],
      ),
    );
  }
}
