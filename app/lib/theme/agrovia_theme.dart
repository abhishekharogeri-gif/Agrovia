import 'package:flutter/material.dart';

class AgroviaColors {
  // Baby-Blue Glassmorphism Palette
  static const Color primary = Color(0xFF38BDF8); // Tailwind Sky 400
  static const Color primaryDark = Color(0xFF0284C7); // Sky 600
  static const Color primaryLight = Color(0xFFE0F2FE); // Sky 100

  static const Color backgroundLight = Color(0xFFF0F9FF); // Sky 50
  static const Color backgroundDark = Color(0xFF0B132B); // Midnight Blue

  static const Color glassSurface = Color(0x33FFFFFF); // 20% White
  static const Color glassBorder = Color(0x4DFFFFFF); // 30% White

  static const Color glassSurfaceDark = Color(0x331E293B); // Dark Glass
  static const Color glassBorderDark = Color(0x4D334155);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);

  static const Color accentGreen = Color(0xFF10B981); // Emerald 500
  static const Color accentWarning = Color(0xFFF59E0B); // Amber 500
  static const Color accentDanger = Color(0xFFEF4444); // Red 500
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
