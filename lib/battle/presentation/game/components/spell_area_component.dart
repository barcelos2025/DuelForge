import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/battle_objects.dart';
import 'vfx_component.dart';

class SpellAreaComponent extends PositionComponent {
  final BattleSpell spell;
  bool _hasVfx = false;

  SpellAreaComponent({required this.spell}) {
    size = Vector2(spell.radius * 2, spell.radius * 2);
    anchor = Anchor.center;
    position = spell.position;
  }

  @override
  Future<void> onLoad() async {
    String? vfxName;
    
    // Map cardId to VFX
    if (spell.cardId.contains('lightning') || spell.cardId.contains('cloud')) {
      vfxName = 'vfx_lightning_cloud';
    } else if (spell.cardId.contains('poison')) {
      vfxName = 'vfx_poison';
    } else if (spell.cardId.contains('hailstorm') || spell.cardId.contains('ice')) {
      vfxName = 'vfx_hailstorm';
    } else if (spell.cardId.contains('voodoo')) {
      vfxName = 'vfx_voodoo';
    } else if (spell.cardId.contains('hammer')) {
      vfxName = 'vfx_thunder_hammer';
    } else if (spell.cardId.contains('spear') || spell.cardId.contains('rain')) {
      vfxName = 'vfx_spear_rain';
    }

    if (vfxName != null) {
      final vfx = VfxComponent(
        vfxName: vfxName,
        position: size / 2, // Center of parent
        size: size, // Match spell area
        loop: spell.duration > 1.5, // Loop if long duration
      );
      
      // We add it, but if it fails to load (file missing), it removes itself.
      // We can check if it loaded successfully? Not easily here async.
      // We'll assume if we added it, we have vfx intent.
      add(vfx);
      _hasVfx = true;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (spell.finished) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    // If we have VFX, we might want to hide the debug circle or make it very subtle
    final opacity = _hasVfx ? 0.1 : 0.3;
    
    final paint = Paint()
      ..color = (spell.side == BattleSide.player ? Colors.cyan : Colors.orange).withOpacity(opacity)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(size.x/2, size.y/2), spell.radius, paint);
    
    // Expanding/Pulsing Ring (Keep this for gameplay clarity of AoE bounds)
    double ringProgress;
    if (spell.duration < 1.0) {
      ringProgress = (spell.elapsed / spell.duration).clamp(0.0, 1.0);
    } else {
      // Pulse every 1s
      ringProgress = (spell.elapsed % 1.0);
    }
    
    final ringRadius = spell.radius * ringProgress;
    canvas.drawCircle(
      Offset(size.x/2, size.y/2), 
      ringRadius, 
      Paint()
        ..color = Colors.white.withOpacity((1.0 - ringProgress) * 0.5) // Fainter
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.15
    );
    
    canvas.drawCircle(
      Offset(size.x/2, size.y/2), 
      spell.radius, 
      Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.1
    );
  }
}
