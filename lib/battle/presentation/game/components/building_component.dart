
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/battle_objects.dart';
import 'health_bar_component.dart';

class BuildingComponent extends PositionComponent with HasGameRef {
  final BattleUnit building;
  Sprite? _sprite;

  BuildingComponent({required this.building}) {
    size = Vector2(2, 2); // Standard building size (2x2 tiles)
    anchor = Anchor.center;
    position = building.position;
  }

  @override
  Future<void> onLoad() async {
    // Health Bar
    add(HealthBarComponent(
      maxHp: building.maxHp,
      getCurrentHp: () => building.hp,
      width: size.x,
    ));
    
    // Lifetime Bar (Blue, below Health)
    // We can add another bar or modify HealthBarComponent to support secondary bar.
    // For now, let's just add a simple rect render for lifetime in render().

    try {
      // Load sprite based on cardId
      // e.g. "building_cannon.png"
      // Fallback to generic
      _sprite = await gameRef.loadSprite('${building.cardId}.png');
    } catch (_) {
      // Fallback
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Buildings don't move, but we might want to shake if hit?
    
    if (building.isDead) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (_sprite != null) {
      _sprite!.render(canvas, size: size);
    } else {
      // Placeholder Shape
      final paint = Paint()..color = building.side == BattleSide.player ? Colors.blue[800]! : Colors.red[800]!;
      canvas.drawRect(size.toRect(), paint);
      
      // Icon or Text
      final textSpan = TextSpan(
        text: "B",
        style: TextStyle(color: Colors.white, fontSize: 10),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset((size.x - textPainter.width)/2, (size.y - textPainter.height)/2));
    }

    // Render Lifetime Bar
    if (building.lifetime > 0) {
      final barWidth = size.x * 0.8;
      final barHeight = 0.2;
      final progress = building.lifetime / 30.0; // Assuming 30s max for now, or store maxLifetime
      // We don't have maxLifetime stored in BattleUnit easily accessible unless we add it.
      // Let's assume 30s for visualization or just show relative.
      // Actually, let's just show a small blue bar at bottom.
      
      final barRect = Rect.fromLTWH(
        (size.x - barWidth) / 2, 
        size.y + 0.1, 
        barWidth * progress.clamp(0.0, 1.0), 
        barHeight
      );
      canvas.drawRect(barRect, Paint()..color = Colors.cyan);
    }
    
    // Render Aura Range (Debug/Visual)
    if (building.auraRadius > 0) {
       canvas.drawCircle(
         Offset(size.x/2, size.y/2), 
         building.auraRadius, 
         Paint()..color = Colors.blue.withOpacity(0.1)..style = PaintingStyle.fill
       );
    }
  }
}
