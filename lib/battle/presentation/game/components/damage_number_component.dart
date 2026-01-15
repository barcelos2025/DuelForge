import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../battle_game.dart';

class DamageNumberComponent extends PositionComponent with HasGameRef<BattleGame> {
  int value;
  double _life = 0;
  final double _duration = 0.8;

  DamageNumberComponent({required this.value, required Vector2 position}) {
    this.position = position;
    anchor = Anchor.center;
    priority = 100; // On top
  }

  void reset(int value, Vector2 position) {
    this.value = value;
    this.position = position;
    _life = 0;
    // Reset other state if needed
  }

  @override
  void update(double dt) {
    super.update(dt);
    _life += dt;
    position.y -= dt * 2.0; // Float up
    
    if (_life >= _duration) {
      gameRef.returnDamageNumber(this);
    }
  }

  @override
  void render(Canvas canvas) {
    final opacity = (1.0 - (_life / _duration)).clamp(0.0, 1.0);
    // Optimization: Skip render if fully transparent
    if (opacity <= 0) return;

    final textSpan = TextSpan(
      text: value.toString(),
      style: TextStyle(
        color: Colors.white.withOpacity(opacity),
        fontSize: 0.6, // World units
        fontWeight: FontWeight.bold,
        shadows: [Shadow(color: Colors.black.withOpacity(opacity), blurRadius: 2)],
      ),
    );
    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(-tp.width/2, -tp.height/2));
  }
}
