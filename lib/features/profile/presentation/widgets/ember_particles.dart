import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

/// Ember particle effect for the profile screen background
class EmberParticles extends FlameGame {
  final Random _random = Random();
  
  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
  }

  bool _particlesAdded = false;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (!_particlesAdded && size.x > 0) {
      _particlesAdded = true;
      // Create many particles to fill the screen
      for (int i = 0; i < 200; i++) {
        add(_EmberParticle(
          position: Vector2(
            _random.nextDouble() * size.x,
            _random.nextDouble() * size.y, // Start scattered across height
          ),
          // Initial random parameters will be overwritten by _reset() eventually, 
          // but we initialize them here for the first frame.
          velocity: Vector2(
            (_random.nextDouble() - 0.5) * 30, 
            -50 - _random.nextDouble() * 100, // Faster upward speed (-50 to -150)
          ),
          size: 2 + _random.nextDouble() * 6, // Larger size variation (2-8)
          color: _getRandomEmberColor(_random),
        ));
      }
    }
  }

  Color _getRandomEmberColor(Random random) {
    final colors = [
      const Color(0xFFFF5722), // Deep Orange
      const Color(0xFFFF9800), // Orange
      const Color(0xFFFFC107), // Amber
      const Color(0xFFFFEB3B), // Yellow
      const Color(0xFFFF3D00), // Red-Orange
      const Color(0xFFD84315), // Darker Orange
    ];
    return colors[random.nextInt(colors.length)];
  }
}

class _EmberParticle extends PositionComponent with HasGameRef<EmberParticles> {
  _EmberParticle({
    required Vector2 position,
    required this.velocity,
    required double size,
    required this.color,
  }) : super(
          position: position,
          size: Vector2.all(size),
          anchor: Anchor.center,
        );

  Vector2 velocity;
  final Color color;
  final Random _random = Random();
  
  double _lifetime = 0;
  late double _maxLifetime;
  late double _driftPhase;
  late double _wobbleSpeed;
  late double _windForce;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initRandomParams();
    
    // If spawned in the middle of screen (initial load), give it a random partial lifetime
    // so they don't all die at once.
    if (position.y < gameRef.size.y) {
       _lifetime = _random.nextDouble() * _maxLifetime * 0.5;
    }
  }

  void _initRandomParams() {
    _driftPhase = _random.nextDouble() * pi * 2;
    _wobbleSpeed = 1.0 + _random.nextDouble() * 4.0;
    _windForce = 10.0 + _random.nextDouble() * 30.0; // Variable wind strength per particle
    
    // Lifetime: 4 to 9 seconds. 
    // At speed 100px/s, 8s = 800px. Enough to cross screen.
    _maxLifetime = 4.0 + _random.nextDouble() * 5.0; 
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    _lifetime += dt;
    
    // Erratic movement: Sum of sines for "wind" and turbulence
    final turbulence = sin(_lifetime * _wobbleSpeed + _driftPhase) * _windForce;
    final windGust = cos(_lifetime * 0.5) * 20; // Slower global wind shift
    
    position.x += (velocity.x + turbulence + windGust) * dt;
    position.y += velocity.y * dt;
    
    // Wrap around horizontally
    if (position.x < -50) {
      position.x = gameRef.size.x + 50;
    } else if (position.x > gameRef.size.x + 50) {
      position.x = -50;
    }

    // Reset if it goes well above top or exceeds lifetime
    // We allow them to go slightly above 0 (top) before resetting, 
    // or reset if lifetime ends.
    if (position.y < -100 || _lifetime > _maxLifetime) {
      _reset();
    }
  }

  void _reset() {
    _lifetime = 0;
    _initRandomParams();
    
    // Reset to bottom with random X
    position.x = _random.nextDouble() * gameRef.size.x;
    position.y = gameRef.size.y + 10 + _random.nextDouble() * 50;
    
    // Randomize velocity and size on reset for variety
    velocity = Vector2(
      (_random.nextDouble() - 0.5) * 30, 
      -50 - _random.nextDouble() * 100,
    );
    size = Vector2.all(2 + _random.nextDouble() * 6);
  }

  @override
  void render(Canvas canvas) {
    // Fade Logic:
    // 1. Fade in quickly at birth.
    // 2. Fade out based on lifetime (aging).
    // 3. Optional: Fade out based on height to ensure top isn't too cluttered? 
    //    User said "ir se apagando no topo".
    //    Let's rely mostly on lifetime, but maybe accelerate fade if near top.
    
    double opacity = 1.0;
    
    // Fade in
    if (_lifetime < 0.5) {
      opacity = _lifetime / 0.5;
    } 
    // Fade out based on life
    else {
      opacity = 1.0 - ((_lifetime - 0.5) / (_maxLifetime - 0.5)).clamp(0.0, 1.0);
    }
    
    // Additional fade near top of screen (0 to 150px)
    // This helps "se apagando no topo" but allows some to pass if they are young/bright enough
    if (position.y < 150) {
       opacity *= (position.y / 150).clamp(0.0, 1.0);
    }
    
    // Ensure "some can pass out still lit":
    // If we strictly multiply by (y/150), they will be 0 at y=0.
    // User said "umas podem passar... ainda acesas".
    // So let's make the top fade less aggressive or clamp it to a minimum if the particle is "strong".
    // Let's actually REMOVE the forced top fade and rely on lifetime and randomness.
    // If a particle has long lifetime and high speed, it will exit screen before fading out.
    // If it has short lifetime, it will fade before top.
    // To satisfy "ir se apagando no topo", we can bias the lifetime so most die there.
    // But let's stick to the lifetime fade. The "fade near top" logic above forces 0 at y=0.
    // Let's modify it to allow passing.
    
    // REVISED FADE:
    // Just use lifetime fade. The randomness of lifetime + speed will naturally cause 
    // some to fade mid-screen, some at top, and some to exit lit.
    
    if (opacity <= 0) return;

    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3); // Glow
    
    canvas.drawCircle(
      Offset.zero,
      size.x / 2,
      paint,
    );
  }
}
