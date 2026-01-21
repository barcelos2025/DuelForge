import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

/// Ice smoke particle effect for the profile screen background
class IceSmokeParticles extends FlameGame {
  final Random _random = Random();
  
  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Create multiple smoke particles
    // We'll add them in onGameResize to ensure we have the correct dimensions
  }

  bool _particlesAdded = false;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (!_particlesAdded && size.x > 0) {
      _particlesAdded = true;
      for (int i = 0; i < 50; i++) { // Increased count
        add(_IceSmokeParticle(
          position: Vector2(
            _random.nextDouble() * size.x,
            _random.nextDouble() * size.y,
          ),
          velocity: Vector2(
            (_random.nextDouble() - 0.5) * 15, // Random horizontal
            (_random.nextDouble() - 0.5) * 15, // Random vertical
          ),
          size: 100 + _random.nextDouble() * 180, // Even larger and softer
          opacity: 0.05 + _random.nextDouble() * 0.10, // More visible (0.05 - 0.15)
        ));
      }
    }
  }
}

class _IceSmokeParticle extends PositionComponent with HasGameRef<IceSmokeParticles> {
  _IceSmokeParticle({
    required Vector2 position,
    required this.velocity,
    required double size,
    required this.opacity,
  }) : super(
          position: position,
          size: Vector2.all(size),
          anchor: Anchor.center,
        );

  final Vector2 velocity;
  final double opacity;
  final Random _random = Random();
  
  double _lifetime = 0;
  late double _maxLifetime;
  late double _driftPhase;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _driftPhase = _random.nextDouble() * pi * 2;
    _maxLifetime = 10.0 + _random.nextDouble() * 5.0; // Randomized lifetime
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    _lifetime += dt;
    
    // Organic drift
    final driftX = sin(_lifetime * 0.3 + _driftPhase) * 10;
    final driftY = cos(_lifetime * 0.4 + _driftPhase) * 10;
    
    position.x += (velocity.x + driftX) * dt;
    position.y += (velocity.y + driftY) * dt;
    
    // Wrap around screen (all sides)
    if (position.y < -size.y) {
      position.y = gameRef.size.y + size.y;
    } else if (position.y > gameRef.size.y + size.y) {
      position.y = -size.y;
    }

    if (position.x < -size.x) {
      position.x = gameRef.size.x + size.x;
    } else if (position.x > gameRef.size.x + size.x) {
      position.x = -size.x;
    }
    
    // Reset after max lifetime
    if (_lifetime > _maxLifetime) {
      _lifetime = 0;
      _maxLifetime = 10.0 + _random.nextDouble() * 5.0;
      // Randomize position on reset to avoid patterns
      position.setValues(
        _random.nextDouble() * gameRef.size.x,
        _random.nextDouble() * gameRef.size.y,
      );
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFFAADDFF).withOpacity(opacity * (1 - _lifetime / _maxLifetime))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50); // Softer blur for smoke feel
    
    // Draw soft circular smoke centered on the component
    canvas.drawCircle(
      Offset.zero,
      size.x / 2,
      paint,
    );
  }
}
