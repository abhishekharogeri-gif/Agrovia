import 'package:flutter/material.dart';

class AgroviaColors {
  // Baby-Blue Glassmorphism Palette
  static const Color primary = Color(0xFF4FA8DE); // Vibrant Baby-Blue / Cyan Accent
  static const Color primaryDark = Color(0xFF2E7BB0); // Deep Sky / Ocean Blue
  static const Color primaryLight = Color(0xFFB8E0F2); // Soft Baby-Blue Mist
  static const Color babyBlueStart = Color(0xFFEAF6FC);
  static const Color babyBlueEnd = Color(0xFFB8E0F2);

  static const Color backgroundLight = Color(0xFFF0F9FF);
  static const Color backgroundDark = Color(0xFF071A2E); // Deep Midnight Navy for rich glass contrast

  static const Color glassSurface = Color(0x26FFFFFF); // 15% White Frost
  static const Color glassBorder = Color(0x33B8E0F2); // Soft Baby-Blue Border

  static const Color glassSurfaceDark = Color(0x33132D4B); // Tinted Baby-Blue Glass
  static const Color glassBorderDark = Color(0x404FA8DE); // Glowing Cyan Border

  static const Color textPrimary = Color(0xFFF8FAFC); // High-contrast crisp text
  static const Color textSecondary = Color(0xFF94A3B8); // Muted slate secondary text

  static const Color accentGreen = Color(0xFF10B981); // Emerald leaf green
  static const Color accentWarning = Color(0xFFF59E0B); // Amber warning
  static const Color accentDanger = Color(0xFFEF4444); // Coral red danger
}

class AgroviaTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AgroviaColors.backgroundLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AgroviaColors.primary,
        brightness: Brightness.light,
        primary: AgroviaColors.primary,
        surface: Colors.white.withValues(alpha: 0.8),
      ),
      fontFamily: 'Manrope',
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AgroviaColors.backgroundDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AgroviaColors.primary,
        brightness: Brightness.dark,
        primary: AgroviaColors.primary,
        surface: const Color(0xFF1E293B).withValues(alpha: 0.8),
      ),
      fontFamily: 'Manrope',
    );
  }
}
