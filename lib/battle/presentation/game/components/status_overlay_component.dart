import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

enum StatusEffectType {
  slow,
  stun,
  curse,
}

class StatusOverlayComponent extends PositionComponent {
  // Active effects
  final Set<StatusEffectType> _activeEffects = {};
  
  // Visual elements
  SpriteComponent? _stunIcon;
  SpriteComponent? _curseIcon;
  
  // Parent reference for tinting
  HasPaint? _targetPaint;

  StatusOverlayComponent() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Locate parent for tinting
    if (parent is HasPaint) {
      _targetPaint = parent as HasPaint;
    }
  }

  void addEffect(StatusEffectType type) {
    if (_activeEffects.contains(type)) return;
    _activeEffects.add(type);
    _applyVisuals(type, true);
  }

  void removeEffect(StatusEffectType type) {
    if (!_activeEffects.contains(type)) return;
    _activeEffects.remove(type);
    _applyVisuals(type, false);
  }

  void _applyVisuals(StatusEffectType type, bool isActive) {
    switch (type) {
      case StatusEffectType.slow:
        _applySlow(isActive);
        break;
      case StatusEffectType.stun:
        _applyStun(isActive);
        break;
      case StatusEffectType.curse:
        _applyCurse(isActive);
        break;
    }
  }

  void _applySlow(bool isActive) {
    if (_targetPaint == null) return;
    
    if (isActive) {
      _targetPaint!.tint(const Color(0xFF0000FF).withOpacity(0.3)); // Blue tint
    } else {
      _targetPaint!.tint(const Color(0x00000000)); // Remove tint
    }
  }

  void _applyStun(bool isActive) {
    if (isActive) {
      // Create stun icon if not exists
      if (_stunIcon == null) {
        // Placeholder: Yellow star circle
        _stunIcon = SpriteComponent(
          size: Vector2.all(16),
          paint: Paint()..color = Colors.yellow, // Fallback if no sprite
          anchor: Anchor.center,
          position: Vector2(0, -40), // Above head
        );
        // Add rotation effect
        _stunIcon!.add(
          RotateEffect.by(
            2 * pi,
            EffectController(duration: 1.0, infinite: true),
          ),
        );
        add(_stunIcon!);
      }
    } else {
      _stunIcon?.removeFromParent();
      _stunIcon = null;
    }
  }

  void _applyCurse(bool isActive) {
    if (isActive) {
      if (_curseIcon == null) {
        // Placeholder: Purple rune
        _curseIcon = SpriteComponent(
          size: Vector2.all(16),
          paint: Paint()..color = Colors.purple,
          anchor: Anchor.center,
          position: Vector2(0, -20), // Center body
        );
        // Add pulse effect
        _curseIcon!.add(
          ScaleEffect.to(
            Vector2.all(1.2),
            EffectController(
              duration: 0.5, 
              reverseDuration: 0.5, 
              infinite: true,
            ),
          ),
        );
        add(_curseIcon!);
      }
    } else {
      _curseIcon?.removeFromParent();
      _curseIcon = null;
    }
  }
}
