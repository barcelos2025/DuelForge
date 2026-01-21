import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Added
import '../../../domain/entities/battle_stats.dart';
import '../assets/asset_registry.dart';
import '../assets/animation_loader.dart'; // Added
import '../assets/animation_loader.dart'; // Added
import 'unit_state_machine.dart';

import '../../../domain/entities/battle_objects.dart'; // Added

class Tower3DFakeComponent extends PositionComponent with HasGameRef {
  final BattleTower tower;
  final UnitStateMachine stateMachine = UnitStateMachine();

  final VoidCallback? onAttackStart;
  final VoidCallback? onDestroy;

  late final SpriteAnimationComponent _body;
  late final TowerHealthBar3DComponent _healthBar;
  
  double _lastHp = 0;
  bool _isDying = false;
  bool get isDying => _isDying;
  static const int _attackFrameIndex = 5;
  
  // Progressive damage tracking
  int _currentPhase = 1;
  Sprite? _damageSprite;

  Tower3DFakeComponent({
    required this.tower,
    this.onAttackStart,
    this.onDestroy,
  }) : super(
    position: tower.position, 
    size: Vector2.all(3.0),
    priority: 10, // High priority to render above other elements
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _body = SpriteAnimationComponent(
      anchor: Anchor.bottomCenter,
      position: size / 2,
    );
    add(_body);

    _healthBar = TowerHealthBar3DComponent(
      maxHp: tower.maxHp,
      getCurrentHp: () => tower.hp,
      isEnemy: tower.side == BattleSide.enemy,
      barWidth: size.x * 0.5, // Halved width relative to tower size
    );
    // Position is handled in update() of the component
    add(_healthBar);

    _lastHp = tower.hp;

    await _updateAnimation();
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Check for phase change (progressive damage)
    if (_shouldUseProgressiveDamage()) {
      final newPhase = _getTowerPhase();
      if (newPhase != _currentPhase) {
        _currentPhase = newPhase;
        _updateAnimation();
      }
    }
    
    // Sync State
    if (tower.isDead && !_isDying) {
      _isDying = true;
      stateMachine.forceState(UnitState.death);
      onDestroy?.call();
      _updateAnimation();
      _healthBar.removeFromParent();
    } else if (!tower.isDead && !_isDying) {
       // Attack Logic (Heuristic or Event driven)
       if (tower.attackCooldown > 0 && tower.attackCooldown < 0.2) {
         // Just attacked
         if (stateMachine.currentState != UnitState.attack) {
            stateMachine.transitionTo(UnitState.attack);
            _updateAnimation();
         }
       }
    }
    
    // Damage Feedback
    if (tower.hp < _lastHp) {
      _body.paint.colorFilter = const ColorFilter.mode(Colors.white, BlendMode.srcATop);
      Future.delayed(const Duration(milliseconds: 100), () {
        _body.paint.colorFilter = null;
      });
    }
    _lastHp = tower.hp;

    _checkAnimationEvents();
  }

  bool _shouldUseProgressiveDamage() {
    return tower.type == TowerType.king;
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

  String _getTowerAssetPath(int phase) {
    if (tower.side == BattleSide.player) {
      return 'towers/tower_player_0$phase.png';
    } else {
      return 'towers/tower_adversario_0$phase.png';
    }
  }

  Future<void> _updateAnimation() async {
    // For king towers (both player and enemy), use progressive damage sprites
    if (_shouldUseProgressiveDamage()) {
      try {
        final phase = _getTowerPhase();
        final assetPath = _getTowerAssetPath(phase);
        _damageSprite = await gameRef.loadSprite(assetPath);
        
        // Create a simple animation with just this sprite
        final animation = SpriteAnimation.spriteList([_damageSprite!], stepTime: 1.0, loop: true);
        _body.animation = animation;
        _body.animationTicker?.reset();
        return;
      } catch (e) {
        debugPrint('Failed to load progressive damage sprite: $e');
        // Fall through to default animation
      }
    }
    
    // Default animation for princess towers
    const dir = 'se'; // Fixed view
    
    String animName = stateMachine.currentState.name;
    if (stateMachine.currentState == UnitState.death) {
      animName = 'destroy';
    }

    final loadedAnim = await AssetRegistry().getAnimation(
      unitId: tower.type == TowerType.king ? 'king_tower' : 'princess_tower',
      anim: animName,
      dir: dir,
    );

    _body.animation = loadedAnim.animation;
    _body.animationTicker?.reset();

    if (stateMachine.currentState == UnitState.attack || 
        stateMachine.currentState == UnitState.death) {
      _body.animation?.loop = false;
    } else {
      _body.animation?.loop = true;
    }
  }

  bool _attackTriggered = false;

  void _checkAnimationEvents() {
    final ticker = _body.animationTicker;
    if (ticker == null) return;

    if (stateMachine.currentState == UnitState.attack) {
      if (ticker.currentIndex == _attackFrameIndex && !_attackTriggered) {
        _attackTriggered = true;
        onAttackStart?.call();
      }
      
      if (ticker.done()) {
        stateMachine.transitionTo(UnitState.idle);
        _updateAnimation();
        _attackTriggered = false;
      }
    }
    
    // Towers usually stay as ruins when destroyed, so we might not remove from parent immediately
    // or we switch to a 'ruin' sprite. For now, we let the animation play out.
  }
}

class TowerHealthBar3DComponent extends PositionComponent with HasGameRef {
  final double maxHp;
  final double Function() getCurrentHp;
  final double barWidth;
  final double barHeight;
  final bool isEnemy;

  TowerHealthBar3DComponent({
    required this.maxHp,
    required this.getCurrentHp,
    required this.isEnemy,
    this.barWidth = 0.5, // Halved width (was 1.0)
    this.barHeight = 0.30, // Doubled height (was 0.15)
  }) : super(anchor: Anchor.center, priority: 100); // High priority to render on top

  @override
  void render(Canvas canvas) {
    final currentHp = getCurrentHp();
    final pct = (currentHp / maxHp).clamp(0.0, 1.0);

    // Background
    canvas.drawRect(
      Rect.fromLTWH(-barWidth / 2, -barHeight / 2, barWidth, barHeight),
      Paint()..color = Colors.black,
    );

    // Health
    canvas.drawRect(
      Rect.fromLTWH(-barWidth / 2, -barHeight / 2, barWidth * pct, barHeight),
      Paint()..color = isEnemy ? const Color(0xFFE91E63) : const Color(0xFF4CAF50),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // 1. Base Position (Relative to Tower Parent)
    // Tower is 3x3. We want bar centered X, and slightly above Y.
    // Parent size is 3.0. Center X is 1.5.
    // Default Y is -0.5 (above).
    
    double targetX = 1.5; // Center of 3.0 width
    // Enemy: Below (3.0 + 0.5) -> 3.5 might be too low if camera is tight. 
    // Let's try 2.5 (overlapping base slightly) or just ensure Z-index.
    // Also, we need to check if it's going off-screen BOTTOM for enemies.
    double targetY = isEnemy ? 2.8 : -0.5; 
    
    // 2. Clamp Logic
    final parentPos = (parent as PositionComponent).position;
    final worldY = parentPos.y + targetY;
    
    // Get Camera Bounds
    double minY = -1000;
    double maxY = 1000;
    try {
       final rect = gameRef.camera.visibleWorldRect;
       minY = rect.top + 0.5;
       maxY = rect.bottom - 0.5;
    } catch (e) {
       // Fallback
    }

    if (worldY < minY) {
      // Push down (Top edge)
      targetY = minY - parentPos.y;
    } else if (worldY > maxY) {
      // Push up (Bottom edge)
      targetY = maxY - parentPos.y;
    }

    position = Vector2(targetX, targetY);
  }
}
