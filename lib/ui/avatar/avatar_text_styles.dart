import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AvatarTextStyles {
  static TextStyle get title => GoogleFonts.rajdhani(
    fontWeight: FontWeight.w600,
    color: const Color(0xFFE8F6FF),
    fontSize: 24,
    letterSpacing: 0.48, // 2% of 24
    shadows: [
      const Shadow(
        color: Color(0x80000000), // #00000080
        blurRadius: 6,
        offset: Offset(0, 2),
      ),
      const Shadow(
        color: Color(0x3300E5FF), // #00E5FF33
        blurRadius: 8,
      ),
    ],
  );

  static TextStyle get characterName => GoogleFonts.cinzel(
    fontWeight: FontWeight.bold,
    fontSize: 32,
    color: const Color(0xFFF8FBFF),
    shadows: [
      const Shadow(
        color: Color(0x553FD2FF), // #3FD2FF55
        blurRadius: 12,
      ),
      const Shadow(
        color: Color(0x99000000), // #00000099
        blurRadius: 8,
        offset: Offset(0, 3),
      ),
    ],
  );

  static TextStyle get characterClass => GoogleFonts.rajdhani(
    fontWeight: FontWeight.w500,
    fontSize: 18,
    color: const Color(0xFF2FE6FF),
    letterSpacing: 0.72, // 4% of 18
    shadows: [
      const Shadow(
        color: Color(0x6600CFFF), // #00CFFF66
        blurRadius: 10,
      ),
    ],
  );
}
