import 'package:flutter/material.dart';
import 'duel_colors.dart';
import 'duel_typography.dart';
import 'duel_ui_tokens.dart';

class DFTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: DuelColors.primary,
      scaffoldBackgroundColor: DuelColors.background,
      
      // Font Family
      fontFamily: DuelTypography.fontUI,
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: DuelTypography.displayLarge,
        displayMedium: DuelTypography.displayMedium,
        displaySmall: DuelTypography.displaySmall,
        bodyLarge: DuelTypography.bodyLarge,
        bodyMedium: DuelTypography.bodyMedium,
        bodySmall: DuelTypography.bodySmall,
        labelSmall: DuelTypography.labelCaps,
      ),

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: DuelColors.primary,
        secondary: DuelColors.secondary,
        surface: DuelColors.surface,
        error: DuelColors.error,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: DuelColors.textPrimary,
      ),

      // Card Theme
      // Card Theme
      cardTheme: CardThemeData(
        color: DuelColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DuelUiTokens.radiusMedium),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        elevation: 0,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: DuelColors.textSecondary,
        size: 24,
      ),
      
      // Divider
      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.1),
        thickness: 1,
        space: DuelUiTokens.spacing24,
      ),
    );
  }

  // Proxies for backward compatibility and ease of use
  static const Color background = DuelColors.background;
  static const Color surface = DuelColors.surface;
  static const Color primary = DuelColors.primary;
  static const Color secondary = DuelColors.secondary;
  static const Color cyan = DuelColors.primary;
  static const Color purple = DuelColors.secondary;
  static const Color gold = DuelColors.accentGold;
  static const Color ice = Color(0xFFB3E5FC); // Light Blue for Ice theme

  static const TextStyle displayLarge = DuelTypography.displayLarge;
  static const TextStyle titleLarge = DuelTypography.displayMedium; // Mapping titleLarge to displayMedium
  static const TextStyle titleMedium = DuelTypography.displaySmall; // Mapping titleMedium to displaySmall
  static const TextStyle labelBold = DuelTypography.labelCaps;
  static const TextStyle bodyText = DuelTypography.bodyMedium;

  static final List<BoxShadow> shadowDepth = DuelUiTokens.shadowMedium;
  static final List<BoxShadow> glowCyan = DuelUiTokens.glowCyan;

  static final BoxDecoration glassPanelDecoration = BoxDecoration(
    color: DuelColors.surface.withOpacity(0.8),
    borderRadius: BorderRadius.circular(DuelUiTokens.radiusMedium),
    border: Border.all(color: Colors.white.withOpacity(0.1)),
    boxShadow: DuelUiTokens.shadowMedium,
  );

  static const LinearGradient gradientMetal = LinearGradient(
    colors: [Color(0xFF424242), Color(0xFF212121)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient gradientGold = LinearGradient(
    colors: [DuelColors.accentGold, Color(0xFFFFA000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
