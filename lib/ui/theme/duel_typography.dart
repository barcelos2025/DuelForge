import 'package:flutter/material.dart';
import 'duel_colors.dart';

class DuelTypography {
  static const String fontDisplay = 'Cinzel';
  static const String fontUI = 'Inter';

  // --- Display / Headings ---
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: DuelColors.textPrimary,
    letterSpacing: 0.6,
    shadows: [
      Shadow(color: Colors.black, offset: Offset(0, 2), blurRadius: 4),
    ],
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: DuelColors.textPrimary,
    letterSpacing: 0.6,
    shadows: [
      Shadow(color: Colors.black, offset: Offset(0, 1), blurRadius: 2),
    ],
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: DuelColors.textPrimary,
    letterSpacing: 0.5,
  );

  // --- UI / Body ---
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontUI,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: DuelColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontUI,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: DuelColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontUI,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: DuelColors.textSecondary,
  );

  // --- Specialized ---
  static const TextStyle labelCaps = TextStyle(
    fontFamily: fontUI,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: DuelColors.textSecondary,
    letterSpacing: 1.2,
  );

  static const TextStyle hudNumber = TextStyle(
    fontFamily: fontUI,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    shadows: [
      Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 2),
    ],
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: fontUI,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );
  
  static const TextStyle rarityLabel = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 12,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );
}
