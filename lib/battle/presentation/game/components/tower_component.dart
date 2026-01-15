
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/battle_objects.dart';
import 'health_bar_component.dart';
import '../../../../core/assets/asset_registry.dart';

class TowerComponent extends PositionComponent with HasGameRef {
  final BattleTower tower;
  Sprite? _sprite;

  TowerComponent({required this.tower}) {
    size = Vector2(3, 3); // 3x3 tiles
    anchor = Anchor.center;
    position = tower.position;
  }

  @override
  Future<void> onLoad() async {
    add(HealthBarComponent(
      maxHp: tower.maxHp,
      getCurrentHp: () => tower.hp,
      width: size.x,
    ));

    try {
      // Try loading specific tower assets if they exist
      // For now, we might not have them, so this will likely fail and use fallback
      final assetName = tower.type == TowerType.king 
          ? (tower.side == BattleSide.player ? 'king_tower_blue.png' : 'king_tower_red.png')
          : (tower.side == BattleSide.player ? 'princess_tower_blue.png' : 'princess_tower_red.png');
      
      // We don't have a specific path in registry for towers yet, assume root or cards
      // Let's try loading from images directly
      _sprite = await gameRef.loadSprite(assetName);
    } catch (_) {
      // Fallback to shapes
    }
  }

  @override
  void render(Canvas canvas) {
    if (_sprite != null) {
      _sprite!.render(canvas, size: size);
      if (tower.side == BattleSide.enemy) {
        canvas.drawRect(size.toRect(), Paint()..color = Colors.red.withOpacity(0.3));
      }
    } else {
      // Fallback Shape
      final color = tower.side == BattleSide.player ? Colors.blue : Colors.red;
      final paint = Paint()..color = color;
      
      // Base
      canvas.drawRect(Rect.fromLTWH(0, size.y * 0.4, size.x, size.y * 0.6), paint);
      
      // Top (Turret)
      canvas.drawRect(Rect.fromLTWH(size.x * 0.2, 0, size.x * 0.6, size.y * 0.4), paint);
      
      // King Indicator
      if (tower.type == TowerType.king) {
        final crownPaint = Paint()..color = Colors.amber;
        canvas.drawCircle(Offset(size.x / 2, size.y * 0.2), size.x * 0.15, crownPaint);
      }
    }
  }
}
