import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFF06101F);
  static const surface = Color(0xFF0B182A);
  static const surface2 = Color(0xFF10233B);
  static const border = Color(0xFF203A58);
  static const primary = Color(0xFF14B8FF);
  static const primaryDeep = Color(0xFF1267FF);
  static const accent = Color(0xFFFF8A1F);
  static const success = Color(0xFF20D980);
  static const danger = Color(0xFFFF4D5F);
  static const text = Color(0xFFF4F8FF);
  static const muted = Color(0xFF91A4BD);
}

abstract final class AppTheme {
  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      surface: AppColors.surface,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.surface,
      dividerColor: AppColors.border,
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontWeight: FontWeight.w800, color: AppColors.text),
        titleLarge: TextStyle(fontWeight: FontWeight.w800, color: AppColors.text),
        titleMedium: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text),
        bodyLarge: TextStyle(color: AppColors.text),
        bodyMedium: TextStyle(color: AppColors.text),
        bodySmall: TextStyle(color: AppColors.muted),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Color(0xFF081627),
        indicatorColor: Color(0x2414B8FF),
        labelTextStyle: WidgetStatePropertyAll(TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.surface2,
        contentTextStyle: TextStyle(color: AppColors.text),
      ),
    );
  }
}
