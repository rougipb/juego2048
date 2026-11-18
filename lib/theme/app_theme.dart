import 'package:flutter/material.dart';

class AppConstants {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 12.0;
  static const double tileRadius = 8.0;
}

class AppTheme {
  // Paletas personalizables para las fichas (Parte B - Preferencias)
  static const List<String> colorSchemes = ['Clásico', 'Océano', 'Esmeralda'];

  static Color getTileColor(int value, Brightness brightness, String scheme) {
    final isDark = brightness == Brightness.dark;
    if (value == 0) {
      return isDark ? const Color(0xFF3C3A32) : const Color(0xFFCDC1B4);
    }

    if (scheme == 'Océano') {
      switch (value) {
        case 2: return isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE0F2FE);
        case 4: return isDark ? const Color(0xFF1D4ED8) : const Color(0xFFBAE6FD);
        case 8: return const Color(0xFF38BDF8);
        case 16: return const Color(0xFF0284C7);
        case 32: return const Color(0xFF0369A1);
        case 64: return const Color(0xFF1E40AF);
        case 128: return const Color(0xFF4F46E5);
        case 256: return const Color(0xFF4338CA);
        case 512: return const Color(0xFF3730A3);
        case 1024: return const Color(0xFF312E81);
        default: return const Color(0xFF1E1B4B);
      }
    } else if (scheme == 'Esmeralda') {
      switch (value) {
        case 2: return isDark ? const Color(0xFF14532D) : const Color(0xFFDCFCE7);
        case 4: return isDark ? const Color(0xFF166534) : const Color(0xFFBBF7D0);
        case 8: return const Color(0xFF4ADE80);
        case 16: return const Color(0xFF22C55E);
        case 32: return const Color(0xFF16A34A);
        case 64: return const Color(0xFF15803D);
        case 128: return const Color(0xFF0D9488);
        case 256: return const Color(0xFF0F766E);
        case 512: return const Color(0xFF115E59);
        case 1024: return const Color(0xFF134E4A);
        default: return const Color(0xFF042F2E);
      }
    }

    // Esquema Clásico 2048
    switch (value) {
      case 2: return isDark ? const Color(0xFF4E4A42) : const Color(0xFFEEE4DA);
      case 4: return isDark ? const Color(0xFF5C5549) : const Color(0xFFEDE0C8);
      case 8: return const Color(0xFFF2B179);
      case 16: return const Color(0xFFF59563);
      case 32: return const Color(0xFFF67C5F);
      case 64: return const Color(0xFFF65E3B);
      case 128: return const Color(0xFFEDCF72);
      case 256: return const Color(0xFFEDCC61);
      case 512: return const Color(0xFFEDC850);
      case 1024: return const Color(0xFFEDC53F);
      case 2048: return const Color(0xFFEDC22E);
      default: return const Color(0xFF3C3A32);
    }
  }

  static Color getTileTextColor(int value, Brightness brightness) {
    if (value <= 4) {
      return brightness == Brightness.dark
          ? const Color(0xFFF9F6F2)
          : const Color(0xFF776E65);
    }
    return const Color(0xFFF9F6F2);
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF8F7A66),
      brightness: Brightness.light,
      surface: const Color(0xFFFAF8EF),
    ),
    scaffoldBackgroundColor: const Color(0xFFFAF8EF),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFF59563),
      brightness: Brightness.dark,
      surface: const Color(0xFF1E1D1B),
    ),
    scaffoldBackgroundColor: const Color(0xFF1E1D1B),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
    ),
  );
}