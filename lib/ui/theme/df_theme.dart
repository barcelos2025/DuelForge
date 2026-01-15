import 'package:flutter/material.dart';

class DFTheme {
  // Cores da Paleta
  static const Color background = Color(0xFF0B1320); // Azul-noite profundo
  static const Color surface = Color(0xFF13243A); // Azul-acinzentado para painéis
  static const Color surfaceLight = Color(0xFF1F3A5A); // Highlight de superfície
  
  static const Color cyan = Color(0xFF00FFFF); // Magia rúnica (Neon)
  static const Color cyanDim = Color(0xFF008B8B);
  
  static const Color gold = Color(0xFFFFC44D); // Ouro / Lendário
  static const Color goldDim = Color(0xFFB8860B);
  
  static const Color purple = Color(0xFFB35CFF); // Épico
  static const Color red = Color(0xFFFF5D5D); // Perigo / Inimigo
  static const Color green = Color(0xFF8BEA7C); // Aliado / Cura
  
  static const Color ice = Color(0xFFA5F2F3); // Gelo / Inverno
  static const Color fire = Color(0xFFFF7F50); // Fogo / Verão

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;

  // Gradientes
  static const LinearGradient gradientBg = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF13243A), Color(0xFF07101B)],
  );

  static const LinearGradient gradientMetal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A5C70), Color(0xFF2C3E50)],
  );

  static const LinearGradient gradientGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD700), Color(0xFFDAA520)],
  );

  // Sombras e Glows
  static List<BoxShadow> glowCyan = [
    BoxShadow(
      color: cyan.withOpacity( 0.4),
      blurRadius: 12,
      spreadRadius: 1,
    ),
  ];

  static List<BoxShadow> shadowDepth = [
    BoxShadow(
      color: Colors.black.withOpacity( 0.5),
      offset: const Offset(0, 4),
      blurRadius: 8,
    ),
  ];

  // Tipografia
  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'Verdana', // Fallback seguro
    fontSize: 28,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.5,
    color: textPrimary,
    shadows: [
      Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4),
    ],
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'Verdana',
    fontSize: 20,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.2,
    color: textPrimary,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    height: 1.4,
  );

  static const TextStyle labelBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w900,
    color: textPrimary,
    letterSpacing: 0.5,
  );

  // Decorações de Container
  static BoxDecoration glassPanelDecoration = BoxDecoration(
    color: surface.withOpacity( 0.85),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withOpacity( 0.1), width: 1),
    boxShadow: shadowDepth,
  );
  
  static BoxDecoration metalBorderDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(22),
    gradient: gradientMetal,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity( 0.6),
        offset: const Offset(0, 2),
        blurRadius: 4,
      ),
    ],
  );
}
