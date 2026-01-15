import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'hit_vfx_library.dart';

class ProjectileComponent extends PositionComponent {
  // Mutable state for pooling
  Vector2 _start = Vector2.zero();
  Vector2 _end = Vector2.zero();
  double _speed = 0;
  double _progress = 0;
  double _totalDistance = 0;
  VoidCallback? _onHitCallback;
  
  // Visuals
  late CircleComponent _visual; // Placeholder for projectile sprite

  ProjectileComponent() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _visual = CircleComponent(
      radius: 4,
      paint: Paint()..color = Colors.orange, // Default fire ball
      anchor: Anchor.center,
    );
    add(_visual);
  }

  void init({
    required Vector2 startPosition,
    required Vector2 targetPosition,
    required double speed,
    Color? color,
    VoidCallback? onHit,
  }) {
    position = startPosition.clone();
    _start = startPosition.clone();
    _end = targetPosition.clone();
    _speed = speed;
    _onHitCallback = onHit;
    
    _totalDistance = _start.distanceTo(_end);
    _progress = 0;
    
    // Reset visual
    if (color != null) {
      _visual.paint.color = color;
    }
    
    // Face target
    lookAt(_end);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (_totalDistance == 0) return;

    // Move
    double moveDist = _speed * dt;
    _progress += moveDist;
    
    if (_progress >= _totalDistance) {
      // Arrived
      position = _end;
      _onHit();
    } else {
      // Lerp
      double t = _progress / _totalDistance;
      position = _start + (_end - _start) * t;
      
      // Optional: Arc height (fake 3D parabola)
      // float height = sin(t * pi) * arcHeight;
      // position.y -= height; // Subtract Y to go "up" in screen space
    }
  }

  void _onHit() {
    _onHitCallback?.call();
    
    // Spawn Hit VFX
    HitVfxLibrary.spawnHitSpark(position);
    
    removeFromParent(); // Return to pool if managed by a pool
  }
}
