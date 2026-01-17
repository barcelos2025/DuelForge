import 'package:flutter/material.dart';

class DuelColors {
  // --- Core Palette ---
  static const Color background = Color(0xFF05080F); // Darker Navy (Almost Black)
  static const Color surface = Color(0xFF0B1221); // Deep Navy
  static const Color surfaceHighlight = Color(0xFF1A2639); // Lighter Navy for hovers/cards
  
  static const Color primary = Color(0xFF00F0FF); // Neon Cyan
  static const Color primaryDim = Color(0xFF00B8D4); // Dimmer Cyan
  
  static const Color secondary = Color(0xFFD500F9); // Neon Purple
  static const Color accentGold = Color(0xFFFFD700); // Gold (Metal)
  static const Color accentOrange = Color(0xFFFF6D00); // Orange (Metal)

  // --- Functional ---
  static const Color textPrimary = Color(0xFFF0F4F8); // White-ish Blue
  static const Color textSecondary = Color(0xFF94A3B8); // Blue Grey
  static const Color textDisabled = Color(0xFF475569);
  
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFEA00);
  static const Color error = Color(0xFFFF1744);

  // --- Rarities ---
  static const Color rarityCommon = Color(0xFFB0BEC5); // Silver/Grey
  static const Color rarityRare = Color(0xFF29B6F6); // Blue (Standard Rare) or Orange? User said "Metal accents". Let's stick to standard game rarities but metallic.
  // User prompt: "Recurso/Tipo -> Raridade -> Poder -> Nível".
  // User prompt: "Metais (dourado/roxo/laranja) só como acento (raridade e CTA)".
  // Let's use:
  // Common: Silver/Grey
  // Rare: Orange/Bronze
  // Epic: Purple
  // Legendary: Gold
  
  // Overriding previous values to match "Metals"
  static const Color rarityCommonMetal = Color(0xFFB0BEC5); 
  static const Color rarityRareMetal = Color(0xFFFF9800); 
  static const Color rarityEpicMetal = Color(0xFFD500F9); 
  static const Color rarityLegendaryMetal = Color(0xFFFFD700); 
  
  // Aliases for backward compatibility
  static const Color rarityEpic = rarityEpicMetal;
  static const Color rarityLegendary = rarityLegendaryMetal; 

  // Gradients
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1AFFFFFF), // 10% White
      Color(0x05FFFFFF), // 2% White
    ],
  );
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF00B0FF)],
  );
}
