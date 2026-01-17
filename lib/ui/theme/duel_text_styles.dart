import 'package:flutter/material.dart';
import 'duel_colors.dart';

class DuelTextStyles {
  static const String fontFamilyTitle = 'Cinzel';
  static const String fontFamilyBody = 'Inter'; // Assuming Inter is available or default

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamilyTitle,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: DuelColors.textPrimary,
    shadows: [
      Shadow(
        color: Colors.black,
        offset: Offset(0, 2),
        blurRadius: 4,
      ),
    ],
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamilyTitle,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: DuelColors.textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: DuelColors.textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: DuelColors.textSecondary,
  );

  static const TextStyle valueLarge = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: DuelColors.primary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 14,
    height: 1.5,
    color: DuelColors.textSecondary,
  );
  
  static const TextStyle buttonText = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: DuelColors.primary,
    letterSpacing: 0.5,
  );
}
