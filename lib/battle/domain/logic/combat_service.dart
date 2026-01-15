
import '../entities/battle_objects.dart';
import '../entities/match_state.dart';
import '../entities/status_effects.dart';

import '../config/battle_tuning.dart';

class CombatService {
  final MatchState state;

  CombatService(this.state);

  void handleAttack(BattleUnit attacker, BattleEntity target, double dt) {
    // Check Cooldown
    if (attacker.attackCooldown > 0) return;
    
    // Check Stun
    if (attacker.isStunned) return;

    // Apply Attack
    attacker.attackCooldown = BattleTuning.debugNoCooldown ? 0.0 : attacker.attackSpeed;
    
    if (attacker.attackType == AttackType.aoe) {
      _applyAoEDamage(attacker, target);
    } else {
      _applySingleTargetDamage(attacker, target);
    }
  }

  void _applySingleTargetDamage(BattleUnit attacker, BattleEntity target) {
    _applyDamageAndEffects(attacker, target);
  }

  void _applyAoEDamage(BattleUnit attacker, BattleEntity target) {
    // AoE centered on target
    final center = target.position;
    final radius = attacker.aoeRadius > 0 ? attacker.aoeRadius : 1.5; // Default AoE

    // Find all enemies in radius
    final enemies = getAllEnemies(attacker.side);
    
    for (var enemy in enemies) {
      if (enemy.isDead) continue;
      if (enemy.position.distanceTo(center) <= radius) {
        _applyDamageAndEffects(attacker, enemy);
      }
    }
  }

  void _applyDamageAndEffects(BattleUnit attacker, BattleEntity target) {
    // Apply Damage
    target.takeDamage(attacker.damage);
    
    // Telemetry
    if (attacker.side == BattleSide.player) {
      state.telemetry.trackDamage(attacker.cardId, attacker.damage);
      if (target.isDead && target is BattleTower) {
        state.telemetry.trackTowerDestroyed();
      }
    }
    
    // Apply On-Hit Effects
    for (var effect in attacker.onHitEffects) {
      // Clone effect to give unique instance
      target.addStatus(StatusEffect(
        type: effect.type,
        value: effect.value,
        duration: effect.duration,
      ));
    }
  }

  List<BattleEntity> getAllEnemies(BattleSide mySide) {
    final enemySide = mySide == BattleSide.player ? BattleSide.enemy : BattleSide.player;
    final targets = <BattleEntity>[];
    targets.addAll(state.units.where((u) => u.side == enemySide && !u.isDead));
    targets.addAll(state.towers.where((t) => t.side == enemySide && !t.isDead));
    return targets;
  }
}
