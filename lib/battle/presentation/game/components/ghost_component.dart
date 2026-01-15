
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../domain/config/battle_field_config.dart';
import '../../../../core/assets/asset_registry.dart';

class GhostComponent extends PositionComponent with HasGameRef {
  final String cardId;
  final bool isSpell;
  final double range;
  final double radius; // For spells
  
  Sprite? _sprite;
  bool isValid = true;

  GhostComponent({
    required this.cardId,
    required this.isSpell,
    this.range = 0,
    this.radius = 0,
  }) {
    size = Vector2(3, 3); // Default size, adjusted later
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    try {
      final path = AssetRegistry.getCardAsset(cardId);
      _sprite = await gameRef.loadSprite(path);
    } catch (e) {
      print('Ghost failed to load sprite: $e');
    }
    
    // Adjust size based on type?
    if (isSpell) {
      size = Vector2(radius * 2, radius * 2);
    } else {
      size = Vector2(2, 2); // Standard unit size
    }
  }

  @override
  void render(Canvas canvas) {
    // Render Range/Radius Indicator
    final color = isValid ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3);
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    
    if (isSpell) {
      // Draw Spell Radius
      canvas.drawCircle(Offset(size.x/2, size.y/2), size.x/2, paint);
    } else {
      // Draw Range Circle if ranged
      if (range > 0) {
        canvas.drawCircle(
          Offset(size.x/2, size.y/2), 
          range, // This might be large, ensure it doesn't clip? 
                 // Flame components don't clip by default unless specified.
          Paint()..color = Colors.white.withOpacity(0.1)..style = PaintingStyle.stroke..strokeWidth = 0.1
        );
      }
      // Draw Placement Footprint
      canvas.drawRect(size.toRect(), paint);
    }

    // Render Sprite
    if (_sprite != null) {
      _sprite!.render(
        canvas, 
        size: size, 
        overridePaint: Paint()..color = (isValid ? Colors.white : Colors.red).withOpacity(0.7)
      );
    } else {
      // Placeholder
      canvas.drawRect(size.toRect(), Paint()..color = isValid ? Colors.blue : Colors.red);
    }
  }
}
