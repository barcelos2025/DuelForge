import 'package:flutter/material.dart';
import 'package:flame/text.dart';

class DuelForgeTextPaints {
  // TODO: Integrar fonte Cinzel se disponível no pubspec.yaml
  static final TextPaint nomeCarta = TextPaint(
    style: const TextStyle(
      fontSize: 14,
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontFamily: 'Cinzel', // Fallback para default se não carregada
      shadows: [
        Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 2),
      ],
    ),
  );

  static final TextPaint nivelBadge = TextPaint(
    style: const TextStyle(
      fontSize: 12,
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontFamily: 'Inter', // Fallback para default
    ),
  );

  static final TextPaint fragmentos = TextPaint(
    style: const TextStyle(
      fontSize: 10,
      color: Color(0xFF00F0FF), // Ciano neon
      fontWeight: FontWeight.bold,
      fontFamily: 'Inter',
      shadows: [
        Shadow(color: Colors.black, offset: Offset(0, 1), blurRadius: 1),
      ],
    ),
  );

  static final TextPaint naoObtida = TextPaint(
    style: const TextStyle(
      fontSize: 12,
      color: Colors.white54,
      fontWeight: FontWeight.bold,
      fontFamily: 'Inter',
    ),
  );
}
