import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/battle_objects.dart';
import '../../../domain/config/battle_tuning.dart';
import '../assets/asset_registry.dart';
import '../assets/animation_loader.dart'; // Added
import 'unit_state_machine.dart';
import 'health_bar_component.dart';
import 'status_overlay_component.dart';

/// Component representing a unit using "3D Fake" spritesheets.
class Unit3DFakeComponent extends PositionComponent {
  final BattleUnit unit;
  final UnitStateMachine stateMachine = UnitStateMachine();
  
  // Callbacks (optional, can be driven by state changes too)
  final VoidCallback? onAttackStart;
  final VoidCallback? onAttackHit;
  final VoidCallback? onDeath;

  // Internal components
  late final SpriteAnimationComponent _body;
  late final HealthBarComponent _healthBar;
  late final StatusOverlayComponent _statusOverlay;
  
  // State tracking
  String _currentDir = 'se'; 
  bool _isFlipped = false;
  double _lastHp = 0;
  bool _isDying = false;
  bool get isDying => _isDying; // Exposed for BattleGame cleanup logic
  
  // Animation configuration
  int _hitFrameIndex = 6; 

  Unit3DFakeComponent({
    required this.unit,
    this.onAttackStart,
    this.onAttackHit,
    this.onDeath,
  }) : super(position: unit.position, size: Vector2.all(2.0)); // Size in world units (approx 2 tiles)

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Body
    _body = SpriteAnimationComponent(
      anchor: Anchor.bottomCenter,
      position: size / 2, 
      size: size * 1.5, // Sprite is larger than hitbox
    );
    add(_body);
    
    // Health Bar
    _healthBar = HealthBarComponent(
      maxHp: unit.maxHp,
      getCurrentHp: () => unit.hp,
      width: size.x,
    );
    _healthBar.position = Vector2(size.x/2 - size.x/2, -0.5);
    add(_healthBar);

    // Status Overlay
    _statusOverlay = StatusOverlayComponent();
    _statusOverlay.position = size / 2;
    add(_statusOverlay);

    _lastHp = unit.hp;

    // Initial state
    await _updateAnimation();
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // 1. Sync Position
    position = unit.position;
    
    // 2. Sync State & Direction
    _syncStateFromDomain();
    
    // 3. Visual Feedback (Damage, Status)
    _handleVisualFeedback();

    // 4. Check Animation Events
    _checkAnimationEvents();
  }

  void _syncStateFromDomain() {
    if (_isDying) return;

    // Death
    if (unit.isDead) {
      _isDying = true;
      stateMachine.forceState(UnitState.death);
      _updateAnimation();
      return;
    }

    // Direction
    Vector2 dirVec = Vector2.zero();
    if (unit.currentTarget != null) {
      dirVec = unit.currentTarget!.position - unit.position;
    } else {
      // Default forward
      dirVec = Vector2(0, unit.side == BattleSide.player ? -1 : 1);
    }

    if (dirVec.length2 > 0) {
      // MVP 2-Direction Logic
      String newDir = _currentDir;
      if (dirVec.y < -0.1) {
        newDir = 'ne'; // Up/Back
      } else if (dirVec.y > 0.1) {
        newDir = 'se'; // Down/Front
      }
      
      bool newFlip = dirVec.x < -0.1; // Flip if facing left

      if (newDir != _currentDir || newFlip != _isFlipped) {
        _currentDir = newDir;
        _isFlipped = newFlip;
        _updateAnimation();
      }
    }

    // State
    UnitState newState = UnitState.idle;
    
    // Simple mapping from domain state (which is implicit in properties)
    if (unit.spawnTimer > 0) {
      newState = UnitState.spawn;
    } else if (unit.attackCooldown > 0 && unit.attackCooldown < 0.3) {
      // Just attacked or about to? 
      // Domain doesn't explicitly say "attacking" duration, usually just cooldown.
      // We trigger attack animation via event or heuristic.
      // For now, let's use a heuristic: if cooldown is high (just reset), we are attacking.
      // Better: BattleUnit should have an 'isAttacking' flag or we trigger 'attack()' method.
      // Since we are polling, let's assume if we are in range and cooldown is max, we attacked.
      // Actually, let's stick to 'walk' vs 'idle' for now, and 'attack' is triggered by cooldown reset?
      // No, that's flaky.
      
      // Let's assume 'attack' state is transient and handled by _checkAnimationEvents or manual trigger.
      // But here we are syncing.
      
      // If we are moving (target far), walk.
      if (unit.currentTarget != null) {
         final dist = unit.position.distanceTo(unit.currentTarget!.position);
         if (dist > unit.range) {
           newState = UnitState.walk;
         } else {
           // In range.
           // If cooldown is near max (just fired), maybe show attack?
           // Let's rely on the fact that if we are NOT walking and NOT dead, we are Idle or Attacking.
           // We can trigger attack animation if we detect a damage event?
           // Or we can just loop 'attack' if dps is high?
           
           // For MVP: If in range, Idle. Attack is a one-shot.
           // We need a way to know when to play attack.
           // Let's look at `unit.attackCooldown`. If it wraps around, we attacked.
           // But we don't store previous cooldown.
           
           // Alternative: The Domain `MatchLoop` could fire events.
           // But we are in polling mode.
           
           // Let's just use Walk vs Idle for now.
           newState = UnitState.idle;
         }
      } else {
        // No target, usually walking forward
        newState = UnitState.walk;
      }
    }

    // Only transition if not currently locked in an animation (like attack windup)
    // For now, simple transition
    if (stateMachine.currentState != UnitState.attack && stateMachine.currentState != UnitState.death) {
      if (stateMachine.currentState != newState) {
        stateMachine.transitionTo(newState);
        _updateAnimation();
      }
    }
  }

  void _handleVisualFeedback() {
    // Damage Numbers
    if (BattleTuning.showDamageNumbers && unit.hp < _lastHp) {
       final dmg = (_lastHp - unit.hp).toInt();
       if (dmg > 0) {
         // Show damage number (need access to game ref or parent)
         // For now, flash white
         _body.paint.colorFilter = const ColorFilter.mode(Colors.white, BlendMode.srcATop);
         Future.delayed(const Duration(milliseconds: 100), () {
           _body.paint.colorFilter = null;
         });
       }
    }
    _lastHp = unit.hp;
    
    // Status Effects
    // We need to check unit.effects (list of strings)
    // Map strings to StatusEffectType
    // _statusOverlay.addEffect(...)
  }

  Future<void> _updateAnimation() async {
    final animName = stateMachine.currentState.name;
    
    final loadedAnim = await AssetRegistry().getAnimation(
      unitId: unit.cardId, // Use cardId as unitId
      anim: animName,
      dir: _currentDir,
    );

    _body.animation = loadedAnim.animation;
    
    // Update metadata
    if (loadedAnim.hitFrame != -1) {
      _hitFrameIndex = loadedAnim.hitFrame;
    } else {
      _hitFrameIndex = 6; // Default
    }
    
    // Handle Flip
    if (_isFlipped) {
      _body.scale = Vector2(-1, 1);
    } else {
      _body.scale = Vector2(1, 1);
    }

    _body.animationTicker?.reset();
    
    if (stateMachine.currentState == UnitState.attack || 
        stateMachine.currentState == UnitState.death ||
        stateMachine.currentState == UnitState.hit) {
      _body.animation?.loop = false;
    } else {
      _body.animation?.loop = true;
    }
  }

  bool _attackHitTriggered = false;

  void _checkAnimationEvents() {
    final ticker = _body.animationTicker;
    if (ticker == null) return;

    // Attack Hit Event
    if (stateMachine.currentState == UnitState.attack) {
      if (ticker.currentIndex == _hitFrameIndex && !_attackHitTriggered) {
        _attackHitTriggered = true;
        onAttackHit?.call();
      }
      
      // Reset trigger if we loop (though attack shouldn't loop usually)
      if (ticker.currentIndex < _hitFrameIndex) {
        _attackHitTriggered = false;
      }

      // End of Attack
      if (ticker.done()) {
        stateMachine.transitionTo(UnitState.idle);
        _updateAnimation();
        _attackHitTriggered = false;
      }
    }

    // Death Event
    if (stateMachine.currentState == UnitState.death) {
      if (ticker.done()) {
        onDeath?.call();
        removeFromParent();
      }
    }
  }
}
