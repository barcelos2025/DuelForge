import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'duel_colors.dart';

class DuelTypography {
  // 3D Shadow Effect Helper
  static const List<Shadow> shadow3D = [
    Shadow(color: Color(0x80000000), offset: Offset(0, 1), blurRadius: 0),
    Shadow(color: Color(0x60000000), offset: Offset(0, 2), blurRadius: 1),
    Shadow(color: Color(0x40000000), offset: Offset(0, 3), blurRadius: 2),
    Shadow(color: Color(0x20000000), offset: Offset(0, 4), blurRadius: 4),
  ];

  static const List<Shadow> shadow3DStrong = [
    Shadow(color: Color(0xA0000000), offset: Offset(0, 2), blurRadius: 0),
    Shadow(color: Color(0x80000000), offset: Offset(0, 3), blurRadius: 1),
    Shadow(color: Color(0x60000000), offset: Offset(0, 4), blurRadius: 2),
    Shadow(color: Color(0x40000000), offset: Offset(0, 6), blurRadius: 4),
    Shadow(color: Color(0x20000000), offset: Offset(0, 8), blurRadius: 8),
  ];

  static const List<Shadow> shadow3DCyan = [
    Shadow(color: DuelColors.primary, offset: Offset(0, 0), blurRadius: 8),
    Shadow(color: Color(0x80000000), offset: Offset(0, 2), blurRadius: 0),
    Shadow(color: Color(0x60000000), offset: Offset(0, 3), blurRadius: 2),
    Shadow(color: Color(0x40000000), offset: Offset(0, 5), blurRadius: 4),
  ];

  // --- Display / Headings ---
  static final TextStyle displayLarge = GoogleFonts.cinzel(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: DuelColors.textPrimary,
    letterSpacing: 0.6,
    shadows: shadow3DStrong,
  );

  static final TextStyle displayMedium = GoogleFonts.cinzel(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: DuelColors.textPrimary,
    letterSpacing: 0.6,
    shadows: shadow3D,
  );

  static final TextStyle displaySmall = GoogleFonts.cinzel(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: DuelColors.textPrimary,
    letterSpacing: 0.5,
    shadows: shadow3D,
  );

  // --- UI / Body ---
  static final TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: DuelColors.textPrimary,
  );

  static final TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: DuelColors.textSecondary,
    height: 1.5,
  );

  static final TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: DuelColors.textSecondary,
  );

  // --- Specialized ---
  static final TextStyle labelCaps = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: DuelColors.textSecondary,
    letterSpacing: 1.2,
  );

  static final TextStyle hudNumber = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    shadows: shadow3D,
  );

  static final TextStyle buttonText = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    shadows: const [
      Shadow(color: Color(0x80000000), offset: Offset(0, 1), blurRadius: 2),
    ],
  );
  
  static final TextStyle rarityLabel = GoogleFonts.cinzel(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
    shadows: shadow3D,
  );
  
  // Font family getters for backward compatibility
  static String get fontDisplay => GoogleFonts.cinzel().fontFamily!;
  static String get fontUI => GoogleFonts.inter().fontFamily!;
}
