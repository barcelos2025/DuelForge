import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../../domain/entities/battle_objects.dart';
import '../../../domain/config/battle_tuning.dart';
import 'health_bar_component.dart';
import '../../../../core/assets/asset_registry.dart';
import '../battle_game.dart';
import 'damage_number_component.dart';

class UnitComponent extends PositionComponent with HasGameRef<BattleGame> {
  final BattleUnit unit;
  Sprite? _sprite;

  bool _isDying = false;
  double _dyingTimer = 0;
  double _lastHp = 0;

  UnitComponent({required this.unit}) {
    size = Vector2(1.5, 1.5); // Standard unit size
    anchor = Anchor.center;
    position = unit.position;
    _lastHp = unit.hp;
  }

  @override
  Future<void> onLoad() async {
    // Health Bar
    add(HealthBarComponent(
      maxHp: unit.maxHp,
      getCurrentHp: () => unit.hp,
      width: size.x,
    ));

    try {
      final path = AssetRegistry.getCardAsset(unit.cardId);
      _sprite = await gameRef.loadSprite(path);
    } catch (e) {
      print('Failed to load sprite for ${unit.cardId}: $e');
      // Fallback handled in render
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Death Logic
    if (unit.isDead) {
      if (!_isDying) {
        _isDying = true;
        // Start death animation
      }
      
      _dyingTimer += dt;
      if (_dyingTimer >= 0.5) {
        removeFromParent();
        return;
      }
      
      // Animate (Scale down & Fade)
      final progress = _dyingTimer / 0.5;
      scale = Vector2.all(1.0 - progress);
      // Opacity handled in render
      
      return; // Stop other updates
    }

    // Damage Detection (Debug)
    if (BattleTuning.showDamageNumbers && unit.hp < _lastHp) {
      final damage = _lastHp - unit.hp;
      if (damage > 1) {
        parent?.add(gameRef.getDamageNumber(
          damage.toInt(), 
          position.clone() + Vector2(0, -size.y/2),
        ));
      }
    }
    _lastHp = unit.hp;
    
    // Sync Position
    position = unit.position;
    
    // Spawn Animation (Scale In)
    if (unit.maxSpawnTime > 0) {
      double progress = 1.0 - (unit.spawnTimer / unit.maxSpawnTime).clamp(0.0, 1.0);
      scale = Vector2.all(progress);
    } else {
      scale = Vector2.all(1.0);
    }
  }

  bool _isVisible() {
    // Simple culling based on fixed camera assumption (Vertical scroll mostly)
    // View is approx 30 units high.
    final camY = gameRef.cameraComponent.viewfinder.position.y;
    final distY = (position.y - camY).abs();
    return distY < 20.0; // 20 units margin
  }

  @override
  void render(Canvas canvas) {
    if (!_isVisible()) return;

    // Opacity for death
    if (_isDying) {
      canvas.saveLayer(null, Paint()..color = Colors.white.withOpacity(1.0 - (_dyingTimer / 0.5).clamp(0.0, 1.0)));
    }

    // Hit Feedback
    Paint? overridePaint;
    if (unit.timeSinceLastHit < BattleTuning.hitFlashDuration) {
      overridePaint = Paint()..colorFilter = const ColorFilter.mode(Colors.white, BlendMode.srcATop);
    }

    if (_sprite != null) {
      canvas.save();
      canvas.clipPath(Path()..addOval(size.toRect()));
      _sprite!.render(canvas, size: size, overridePaint: overridePaint);
      
      // Tint for enemy
      if (unit.side == BattleSide.enemy && overridePaint == null) {
        canvas.drawRect(size.toRect(), Paint()..color = Colors.red.withOpacity(0.3));
      }
      canvas.restore();

      // Border
      final color = unit.side == BattleSide.player ? Colors.cyan : Colors.orange;
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        size.x / 2,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.1,
      );
    } else {
      // Fallback Circle
      final color = unit.side == BattleSide.player ? Colors.cyan : Colors.orange;
      final paint = overridePaint ?? (Paint()..color = color);
      canvas.drawCircle(Offset(size.x/2, size.y/2), size.x/2, paint);
      
      // Fallback Text
      final textSpan = TextSpan(
        text: unit.cardId.split('_').last.replaceAll(RegExp(r'\..*'), ''), // Short name
        style: const TextStyle(color: Colors.white, fontSize: 10),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: size.x * 20);
      
      final textSpanScaled = TextSpan(
        text: unit.cardId.substring(0, min(5, unit.cardId.length)),
        style: const TextStyle(color: Colors.black, fontSize: 0.4),
      );
      final tp = TextPainter(text: textSpanScaled, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset((size.x - tp.width) / 2, (size.y - tp.height) / 2));
    }
    
    // Status Icons
    if (unit.isStunned) {
      const iconSize = 0.5;
      const iconOffset = Offset(0, -0.5); // Above center
      canvas.drawCircle(Offset(size.x/2, 0) + iconOffset, iconSize/2, Paint()..color = Colors.yellow);
      // Simple Bolt shape or just yellow circle
    } else if (unit.isConfused) {
      const iconSize = 0.5;
      const iconOffset = Offset(0, -0.5);
      canvas.drawCircle(Offset(size.x/2, 0) + iconOffset, iconSize/2, Paint()..color = Colors.purpleAccent);
    } else if (unit.currentSpeed < unit.speed) { // Slowed
      const iconSize = 0.5;
      const iconOffset = Offset(0, -0.5);
      canvas.drawCircle(Offset(size.x/2, 0) + iconOffset, iconSize/2, Paint()..color = Colors.blueAccent);
    }

    if (_isDying) {
      canvas.restore();
    }
  }
}
