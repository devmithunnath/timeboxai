import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF191919); // Dark background
  static const Color card = Color(
    0xFF2C2C2C,
  ); // Slightly lighter for cards/inputs
  static const Color accent = Color(0xFFD0FD3E); // Neon Lime Green
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E8E);
  static const Color buttonSurface = Color(0xFF333333);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: accent,
      fontFamily: '.SF Pro Text', // Native font on macOS
      colorScheme: const ColorScheme.dark(
        primary: accent,
        surface: background,
        onPrimary: Colors.black, // Text on accent should be dark
        onSurface: textPrimary,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 60,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -1.0,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 14, color: textSecondary),
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
