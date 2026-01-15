import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Added
import '../../../domain/entities/battle_stats.dart';
import '../assets/asset_registry.dart';
import '../assets/animation_loader.dart'; // Added
import 'health_bar_component.dart';
import 'unit_state_machine.dart';

import '../../../domain/entities/battle_objects.dart'; // Added

class Building3DFakeComponent extends PositionComponent {
  final BattleUnit building;
  final UnitStateMachine stateMachine = UnitStateMachine();
  
  // Callbacks
  final VoidCallback? onAttackStart;
  final VoidCallback? onDeath;

  // Internal
  late final SpriteAnimationComponent _body;
  late final HealthBarComponent _healthBar;
  
  double _lastHp = 0;
  bool _isDying = false;
  bool get isDying => _isDying;

  // Configuration
  static const int _attackFrameIndex = 4; // Example trigger frame

  Building3DFakeComponent({
    required this.building,
    this.onAttackStart,
    this.onDeath,
  }) : super(position: building.position, size: Vector2.all(2.0)); // Size adjusted by sprite

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _body = SpriteAnimationComponent(
      anchor: Anchor.bottomCenter,
      position: size / 2,
    );
    add(_body);

    _healthBar = HealthBarComponent(
      maxHp: building.maxHp,
      getCurrentHp: () => building.hp,
      width: size.x,
    );
    _healthBar.position = Vector2(size.x / 2 - size.x/2, -0.5);
    add(_healthBar);

    _lastHp = building.hp;

    await _updateAnimation();
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Sync State
    if (building.isDead && !_isDying) {
      _isDying = true;
      stateMachine.forceState(UnitState.death);
      onDeath?.call();
      _updateAnimation();
      _healthBar.removeFromParent();
    } else if (!building.isDead && !_isDying) {
       // Attack Logic
       if (building.attackCooldown > 0 && building.attackCooldown < 0.2) {
         if (stateMachine.currentState != UnitState.attack) {
            stateMachine.transitionTo(UnitState.attack);
            _updateAnimation();
         }
       }
    }
    
    // Damage Feedback
    if (building.hp < _lastHp) {
      _body.paint.colorFilter = const ColorFilter.mode(Colors.white, BlendMode.srcATop);
      Future.delayed(const Duration(milliseconds: 100), () {
        _body.paint.colorFilter = null;
      });
    }
    _lastHp = building.hp;

    _checkAnimationEvents();
  }

  Future<void> _updateAnimation() async {
    // Buildings usually don't rotate, so we use a fixed direction like 'se' (Front) or 'idle' if no dir
    // The AssetRegistry expects a direction. We'll assume 'se' is the standard front view for buildings.
    const dir = 'se'; 
    
    // Map 'destroy' state to 'death' animation name if needed, or keep as is.
    // Our standard says 'destroy' for buildings, but UnitStateMachine uses 'death'.
    // Let's map UnitState.death -> 'destroy' string for buildings if that's the asset name.
    String animName = stateMachine.currentState.name;
    if (stateMachine.currentState == UnitState.death) {
      animName = 'destroy';
    }

    final loadedAnim = await AssetRegistry().getAnimation(
      unitId: building.cardId,
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

    if (stateMachine.currentState == UnitState.death) { // Destroy state
      if (ticker.done()) {
        removeFromParent();
      }
    }
  }
}
