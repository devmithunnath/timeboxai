import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Colors - Warm, cozy palette matching the background
  static const Color background = Color(0xFF2D1F1A);
  static const Color card = Color(0xFF3D2E28);
  static const Color accent = Color(0xFFE85A3C);
  static const Color textPrimary = Color(0xFFFFF8F0);
  static const Color textSecondary = Color(0xFFB8A090);
  static const Color buttonSurface = Color(0xFF4A3830);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: accent,
      fontFamily: '.SF Pro Text',
      colorScheme: const ColorScheme.dark(
        primary: accent,
        surface: background,
        onPrimary: textPrimary,
        onSurface: textPrimary,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 2,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: textSecondary),
      ),
      iconTheme: const IconThemeData(color: textPrimary),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonSurface,
          foregroundColor: textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
