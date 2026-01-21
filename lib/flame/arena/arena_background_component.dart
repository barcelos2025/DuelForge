import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'arena_controller.dart';

/// Componente responsável por desenhar o background da arena.
/// Renderiza o chão, o rio e as pontes baseando-se nas coordenadas do ArenaController.
class ArenaBackgroundComponent extends PositionComponent {
  final ArenaController controller;
  
  // Paints
  final Paint _paintChao = Paint()..color = const Color(0xFF2E2E2E); // Cinza escuro (pedra)
  final Paint _paintRio = Paint()..color = const Color(0xFF0D47A1); // Azul escuro (água profunda)
  final Paint _paintRioBorda = Paint()..color = const Color(0xFF42A5F5).withOpacity(0.3); // Azul claro (espuma)
  final Paint _paintPonte = Paint()..color = const Color(0xFF5D4037); // Marrom (madeira/pedra)
  final Paint _paintGrid = Paint()
    ..color = Colors.white.withOpacity(0.05)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  ArenaBackgroundComponent({required this.controller}) : super(priority: -100); // Fundo absoluto

  @override
  void render(Canvas canvas) {
    // 1. Chão (Fundo total)
    // Desenha um retângulo cobrindo toda a arena
    canvas.drawRect(
      Rect.fromLTWH(0, 0, controller.tamanhoArena.x, controller.tamanhoArena.y),
      _paintChao,
    );

    // 1.1 Grid (Opcional, para dar textura de tiles)
    _desenharGrid(canvas);

    // 2. Rio
    // Desenha o rio atravessando a arena
    canvas.drawRect(controller.rioRect, _paintRio);
    
    // Bordas do rio (efeito visual simples)
    canvas.drawRect(
      Rect.fromLTRB(
        controller.rioRect.left, 
        controller.rioRect.top, 
        controller.rioRect.right, 
        controller.rioRect.top + 10
      ),
      _paintRioBorda,
    );
    canvas.drawRect(
      Rect.fromLTRB(
        controller.rioRect.left, 
        controller.rioRect.bottom - 10, 
        controller.rioRect.right, 
        controller.rioRect.bottom
      ),
      _paintRioBorda,
    );

    // 3. Pontes
    canvas.drawRect(controller.ponteEsquerdaRect, _paintPonte);
    canvas.drawRect(controller.ponteDireitaRect, _paintPonte);
    
    // Detalhe das pontes (tábuas)
    _desenharDetalhesPonte(canvas, controller.ponteEsquerdaRect);
    _desenharDetalhesPonte(canvas, controller.ponteDireitaRect);
  }

  void _desenharGrid(Canvas canvas) {
    const double step = 100.0;
    final w = controller.tamanhoArena.x;
    final h = controller.tamanhoArena.y;

    // Linhas Verticais
    for (double x = 0; x <= w; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), _paintGrid);
    }

    // Linhas Horizontais
    for (double y = 0; y <= h; y += step) {
      canvas.drawLine(Offset(0, y), Offset(w, y), _paintGrid);
    }
  }

  void _desenharDetalhesPonte(Canvas canvas, Rect ponte) {
    final paintDetalhe = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..strokeWidth = 2;

    // Desenha linhas horizontais simulando tábuas
    for (double y = ponte.top + 10; y < ponte.bottom; y += 20) {
      canvas.drawLine(
        Offset(ponte.left, y),
        Offset(ponte.right, y),
        paintDetalhe,
      );
    }
  }
}
