import 'package:flutter/material.dart';

/// Central color + type palette for BankEasy.
/// Kept deliberately restrained: one navy, one neutral background,
/// one accent used sparingly. See /docs design rationale in README.
class AppColors {
  static const navy = Color(0xFF0F2A4A);
  static const navyLight = Color(0xFF1C3A5E);
  static const ink = Color(0xFF1C2431);
  static const background = Color(0xFFF4F2EC);
  static const cardBorder = Color(0xFFD9D5C8);
  static const muted = Color(0xFF6B6455);
  static const mutedLight = Color(0xFF8A8578);
  static const gold = Color(0xFFB8860B);
  static const goldTint = Color(0xFFEDE8D8);
  static const goldTintText = Color(0xFF5B532F);
  static const danger = Color(0xFFB3413E);
  static const success = Color(0xFF3F7D52);
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.navy,
        primary: AppColors.navy,
        secondary: AppColors.gold,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.cardBorder, width: 0.6),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      fontFamily: 'Roboto',
    );
  }

  /// Serif style used only inside the "paper" preview, to visually
  /// distinguish a generated document from the app's own chrome.
  static const paperTextStyle = TextStyle(
    fontFamily: 'Georgia',
    color: AppColors.ink,
    fontSize: 13,
    height: 1.9,
  );
}
