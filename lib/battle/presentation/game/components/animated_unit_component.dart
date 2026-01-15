import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../../domain/entities/battle_objects.dart';
import '../../../domain/config/battle_tuning.dart';
import 'health_bar_component.dart';
import '../battle_game.dart';

enum UnitAnimationState {
  idle,
  walk,
  attack,
  hit,
  death,
  cast,
}

enum UnitDirection {
  up,
  down,
  // Future: upRight, right, downRight, etc.
}

class UnitAnimationLoader {
  static Future<SpriteAnimation?> load(
    String unitId, 
    UnitAnimationState state, 
    UnitDirection direction,
    BattleGame game,
  ) async {
    // Naming convention: <unitId>/<state>_<dir>.png
    // Example: df_unit_archer_v01/walk_s.png
    // For now, we assume 's' is down and 'n' is up.
    
    String dirSuffix = direction == UnitDirection.down ? 's' : 'n';
    String stateName = state.name;
    
    // Map internal state names to file names if needed
    // e.g. cast -> attack for now if cast is missing
    
    final path = 'units/$unitId/${stateName}_$dirSuffix.png';
    final jsonPath = 'units/$unitId/${stateName}_$dirSuffix.json';

    try {
      // Check if file exists (Flame doesn't have direct check, try load)
      // For optimization, we should have an AssetRegistry manifest.
      // Here we try to load TexturePacker atlas
      
      final spriteSheet = await game.images.load(path);
      final atlas = await game.assets.readJson(jsonPath);
      
      return SpriteAnimation.fromAsepriteData(
        spriteSheet, 
        atlas,
      );
    } catch (e) {
      // Fallback: Try loading simple spritesheet if atlas fails?
      // Or return null to trigger placeholder
      // print('Animation asset not found: $path');
      return null;
    }
  }
}

class AnimatedUnitComponent extends PositionComponent with HasGameRef<BattleGame> {
  final BattleUnit unit;
  
  // State Machine
  UnitAnimationState _currentState = UnitAnimationState.idle;
  UnitDirection _currentDirection = UnitDirection.down;
  
  // Animations Cache
  final Map<String, SpriteAnimation> _animations = {};
  SpriteAnimationComponent? _animComponent;
  
  // Fallback
  bool _useFallback = false;
  Sprite? _fallbackSprite;

  // Visuals
  bool _isDying = false;
  double _dyingTimer = 0;
  double _lastHp = 0;

  AnimatedUnitComponent({required this.unit}) {
    size = Vector2(1.5, 1.5); // Standard unit size
    anchor = Anchor.center;
    position = unit.position;
    _lastHp = unit.hp;
  }

  @override
  Future<void> onLoad() async {
    // Health Bar
    add(HealthBarComponent(
      maxHp: unit.maxHp,
      getCurrentHp: () => unit.hp,
      width: size.x,
    ));

    // Initial Load
    await _updateAnimation(force: true);
    
    if (_useFallback) {
       // Load static sprite as fallback
       try {
         // Try to load card image as fallback
         _fallbackSprite = await gameRef.loadSprite('cards/${unit.cardId}.jpg'); 
       } catch (e) {
         // Final fallback is drawn circle
       }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // 1. Sync Data
    position = unit.position;
    
    // 2. Determine State & Direction
    _updateStateAndDirection();
    
    // 3. Update Animation Component if changed
    _updateAnimation();

    // 4. Death Logic
    if (unit.isDead) {
      if (!_isDying) {
        _isDying = true;
        _currentState = UnitAnimationState.death;
        _updateAnimation(force: true);
      }
      
      _dyingTimer += dt;
      if (_dyingTimer >= 1.0) { // Death anim duration
        removeFromParent();
        return;
      }
      
      // Fade out near end
      if (_dyingTimer > 0.8) {
         final opacity = 1.0 - ((_dyingTimer - 0.8) / 0.2);
         _animComponent?.paint.color = Colors.white.withOpacity(opacity.clamp(0.0, 1.0));
      }
      return;
    }

    // 5. Damage Numbers
    if (BattleTuning.showDamageNumbers && unit.hp < _lastHp) {
      final damage = _lastHp - unit.hp;
      if (damage > 1) {
        parent?.add(gameRef.getDamageNumber(
          damage.toInt(), 
          position.clone() + Vector2(0, -size.y/2),
        ));
      }
      // Hit Flash
      if (_animComponent != null) {
        _animComponent!.paint.colorFilter = const ColorFilter.mode(Colors.white, BlendMode.srcATop);
        Future.delayed(const Duration(milliseconds: 100), () {
           if (isMounted) _animComponent?.paint.colorFilter = null;
        });
      }
    }
    _lastHp = unit.hp;
  }

  void _updateStateAndDirection() {
    if (_isDying) return;

    // Direction
    if (unit.currentTarget != null) {
      final dirVec = unit.currentTarget!.position - unit.position;
      if (dirVec.y < -0.1) {
        _currentDirection = UnitDirection.up;
      } else if (dirVec.y > 0.1) {
        _currentDirection = UnitDirection.down;
      }
    } else {
      // Default movement direction
      final forwardY = unit.side == BattleSide.player ? -1.0 : 1.0;
      _currentDirection = forwardY < 0 ? UnitDirection.up : UnitDirection.down;
    }

    // State
    if (unit.spawnTimer > 0) {
      _currentState = UnitAnimationState.idle; // Or spawn
    } else if (unit.attackCooldown > 0 && unit.attackCooldown < 0.5) {
      _currentState = UnitAnimationState.attack;
    } else if (unit.currentTarget != null && unit.position.distanceTo(unit.currentTarget!.position) <= unit.range) {
       // In range but waiting cooldown
       _currentState = UnitAnimationState.idle;
    } else {
       // Moving
       _currentState = UnitAnimationState.walk;
    }
  }

  Future<void> _updateAnimation({bool force = false}) async {
    final key = '${_currentState.name}_${_currentDirection.name}';
    
    // Check if we need to switch
    // Note: We don't have a simple way to check current anim key in Flame without storing it.
    // Let's assume if state/dir changed, we update.
    
    // Optimization: Only update if changed.
    // We need to store last state/dir.
    // For now, let's just do it.
    
    if (!force && _animComponent?.playing == true) {
       // If playing same animation, don't interrupt?
       // We need a robust key check.
       // Let's skip for now and implement simple loading.
    }

    // Load if not in cache
    if (!_animations.containsKey(key)) {
      final anim = await UnitAnimationLoader.load(unit.cardId, _currentState, _currentDirection, gameRef);
      if (anim != null) {
        _animations[key] = anim;
      } else {
        // Mark as fallback for this state
        _useFallback = true;
      }
    }

    if (_animations.containsKey(key)) {
      _useFallback = false;
      final anim = _animations[key]!;
      
      if (_animComponent == null) {
        _animComponent = SpriteAnimationComponent(
          animation: anim,
          size: size,
          anchor: Anchor.center,
        );
        add(_animComponent!);
      } else {
        if (_animComponent!.animation != anim) {
          _animComponent!.animation = anim;
          // Reset frame if switching anim
          _animComponent!.animationTicker?.reset();
        }
      }
      
      // Flip horizontally if needed (for 8-dir later)
      // For now, just up/down.
      
    } else {
      _useFallback = true;
      _animComponent?.removeFromParent();
      _animComponent = null;
    }
  }

  @override
  void render(Canvas canvas) {
    if (_useFallback) {
      _renderFallback(canvas);
    }
    super.render(canvas); // Renders children (AnimComponent, HealthBar)
  }

  void _renderFallback(Canvas canvas) {
    // Same fallback logic as UnitComponent
    if (_fallbackSprite != null) {
      canvas.save();
      canvas.clipPath(Path()..addOval(size.toRect()));
      _fallbackSprite!.render(canvas, size: size);
      canvas.restore();
    } else {
      final color = unit.side == BattleSide.player ? Colors.cyan : Colors.orange;
      canvas.drawCircle(Offset(size.x/2, size.y/2), size.x/2, Paint()..color = color);
    }
    
    // Border
    final color = unit.side == BattleSide.player ? Colors.cyan : Colors.orange;
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.1,
    );
  }
}
