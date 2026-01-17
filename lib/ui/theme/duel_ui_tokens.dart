import 'package:flutter/material.dart';

class DuelUiTokens {
  // --- Spacing ---
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing48 = 48.0;

  // --- Radius ---
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 24.0;
  static const double radiusFull = 999.0;

  // --- Blur ---
  static const double blurGlass = 10.0;

  // --- Shadows ---
  static final List<BoxShadow> shadowLow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static final List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> shadowHigh = [
    BoxShadow(
      color: Colors.black.withOpacity(0.5),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static final List<BoxShadow> glowCyan = [
    BoxShadow(
      color: const Color(0xFF00F0FF).withOpacity(0.4),
      blurRadius: 12,
      spreadRadius: 1,
    ),
  ];
}
