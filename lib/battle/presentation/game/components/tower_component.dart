
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/battle_objects.dart';
import 'health_bar_component.dart';
import '../../../../core/assets/asset_registry.dart';

class TowerComponent extends PositionComponent with HasGameRef {
  final BattleTower tower;
  Sprite? _sprite;
  int _currentPhase = 1;

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

    await _loadTowerSprite();
  }

  Future<void> _loadTowerSprite() async {
    try {
      final phase = _getTowerPhase();
      final assetName = _getTowerAssetName(phase);
      _sprite = await gameRef.loadSprite(assetName);
      _currentPhase = phase;
    } catch (e) {
      // Fallback to shapes if sprite loading fails
      _sprite = null;
    }
  }

  int _getTowerPhase() {
    final hpPercent = (tower.hp / tower.maxHp * 100).clamp(0, 100);
    
    if (hpPercent > 80) return 1;      // 100% - 81%: Intact
    if (hpPercent > 60) return 2;      // 80% - 61%: Minor damage
    if (hpPercent > 40) return 3;      // 60% - 41%: Medium damage
    if (hpPercent > 20) return 4;      // 40% - 21%: Advanced damage
    if (hpPercent > 0) return 5;       // 20% - 1%: Almost destroyed
    return 6;                          // 0%: Destroyed/ruins
  }

  String _getTowerAssetName(int phase) {
    // For player's king tower (central tower at bottom)
    if (tower.type == TowerType.king && tower.side == BattleSide.player) {
      return 'towers/tower_player_0$phase.png';
    }
    
    // For enemy towers or princess towers, use existing logic
    // (You can expand this later with enemy tower phases)
    if (tower.side == BattleSide.enemy) {
      return tower.type == TowerType.king 
          ? 'king_tower_red.png' 
          : 'princess_tower_red.png';
    }
    
    // Player princess towers (side towers)
    return 'princess_tower_blue.png';
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Check if tower phase has changed
    final newPhase = _getTowerPhase();
    if (newPhase != _currentPhase) {
      _loadTowerSprite();
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
