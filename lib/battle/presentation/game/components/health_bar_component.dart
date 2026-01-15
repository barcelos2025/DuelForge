
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class HealthBarComponent extends PositionComponent {
  final double maxHp;
  final double Function() getCurrentHp;
  final double width;
  final double height;

  HealthBarComponent({
    required this.maxHp,
    required this.getCurrentHp,
    this.width = 1.0, // World units
    this.height = 0.15, // World units
  }) {
    // Position relative to parent (Unit/Tower)
    // Usually above the unit
    position = Vector2(0, -0.5); 
    anchor = Anchor.center;
  }

  @override
  void render(Canvas canvas) {
    final currentHp = getCurrentHp();
    final pct = (currentHp / maxHp).clamp(0.0, 1.0);

    // Background
    canvas.drawRect(
      Rect.fromLTWH(-width / 2, -height / 2, width, height),
      Paint()..color = Colors.black,
    );

    // Health
    canvas.drawRect(
      Rect.fromLTWH(-width / 2, -height / 2, width * pct, height),
      Paint()..color = _getColor(pct),
    );
  }

  Color _getColor(double pct) {
    if (pct > 0.6) return Colors.green;
    if (pct > 0.3) return Colors.yellow;
    return Colors.red;
  }
}
