import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Added
import '../../../domain/entities/battle_stats.dart';
import '../assets/asset_registry.dart';
import '../assets/animation_loader.dart'; // Added
import 'health_bar_component.dart';
import 'unit_state_machine.dart';

import '../../../domain/entities/battle_objects.dart'; // Added

class Tower3DFakeComponent extends PositionComponent {
  final BattleTower tower;
  final UnitStateMachine stateMachine = UnitStateMachine();

  final VoidCallback? onAttackStart;
  final VoidCallback? onDestroy;

  late final SpriteAnimationComponent _body;
  late final HealthBarComponent _healthBar;
  
  double _lastHp = 0;
  bool _isDying = false;
  bool get isDying => _isDying;
  static const int _attackFrameIndex = 5;

  Tower3DFakeComponent({
    required this.tower,
    this.onAttackStart,
    this.onDestroy,
  }) : super(position: tower.position, size: Vector2.all(3.0)); // Size in world units

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _body = SpriteAnimationComponent(
      anchor: Anchor.bottomCenter,
      position: size / 2,
    );
    add(_body);

    _healthBar = HealthBarComponent(
      maxHp: tower.maxHp,
      getCurrentHp: () => tower.hp,
      width: size.x,
    );
    _healthBar.position = Vector2(size.x / 2 - size.x/2, -0.5);
    add(_healthBar);

    _lastHp = tower.hp;
    add(_healthBar);

    await _updateAnimation();
  }

  @override
  void update(double dt) {
    super.update(dt);
    
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

  Future<void> _updateAnimation() async {
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
