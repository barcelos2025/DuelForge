
import '../entities/match_state.dart';
import '../entities/battle_objects.dart';
import '../entities/status_effects.dart';
import 'targeting_system.dart';
import 'package:flame/components.dart'; // For Vector2
import '../controllers/bot_controller.dart';
import '../config/battle_field_config.dart';
import '../../data/balance_rules.dart';
import '../../data/card_catalog.dart';
import 'combat_service.dart';
import '../config/battle_tuning.dart';
import 'dart:math';

import '../models/replay_data.dart';
import '../commands/battle_command.dart';
// ... imports

class MatchLoop {
  final MatchState state;
  final BotController? botController;
  late final CombatService combatService;
  int _replayEventIndex = 0;
  final List<BattleCommand> _commandQueue = [];

  MatchLoop(this.state, {this.botController}) {
    combatService = CombatService(state);
  }

  void enqueueCommand(BattleCommand command) {
    _commandQueue.add(command);
    // Ensure chronological order if needed, but usually appended in order
    _commandQueue.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  void update(double dt) {
    if (state.phase != MatchPhase.active && state.phase != MatchPhase.overtime) return;

    final gameDt = dt * BattleTuning.gameSpeed;

    state.timeElapsed += gameDt;

    // 1. Process Commands
    while (_commandQueue.isNotEmpty) {
      final cmd = _commandQueue.first;
      if (cmd.timestamp <= state.timeElapsed) {
        _processCommand(cmd);
        _commandQueue.removeAt(0);
      } else {
        break;
      }
    }

    // Replay Logic
    if (state.isReplay && state.replayData != null) {
      while (_replayEventIndex < state.replayData!.events.length) {
        final event = state.replayData!.events[_replayEventIndex];
        if (event.timestamp <= state.timeElapsed) {
          spawnUnit(event.cardId, Vector2(event.x, event.y), event.side);
          _replayEventIndex++;
        } else {
          break;
        }
      }
    }

    // 2. Tick Power (Elixir)
    _tickPower(gameDt);
// ...

    // 2. Tick Units & Combat
    _tickUnits(gameDt);
    _tickTowers(gameDt);

    // 3. Tick Spells
    _tickSpells(gameDt);
    
    // 4. Tick Status Effects
    _tickStatus(gameDt);

    // 5. Bot Logic
    if (!state.isReplay && botController != null) {
      final botPlay = botController!.update(gameDt);
      if (botPlay != null) {
        spawnUnit(botPlay.cardId, botPlay.position, BattleSide.enemy);
      }
    }

    // 6. Check End Condition
    state.checkEndCondition();
  }

  void _tickPower(double dt) {
    // Check Overtime trigger
    if (!state.isOvertime && state.timeElapsed >= 120.0) {
      state.isOvertime = true;
      state.playerPower.setOvertime(true);
      state.enemyPower.setOvertime(true);
    }

    state.playerPower.tick(dt, state.timeElapsed, state.matchTimeTotal);
    state.enemyPower.tick(dt, state.timeElapsed, state.matchTimeTotal);
  }

  void _tickUnits(double dt) {
    for (var unit in state.units) {
      if (unit.isDead) continue;

      // Cooldown Tick
      if (unit.attackCooldown > 0) {
        unit.attackCooldown -= dt;
      }

      // Building Logic
      if (unit.isBuilding) {
        unit.lifetime -= dt;
        if (unit.lifetime <= 0) {
           unit.takeDamage(unit.maxHp * 0.1 * dt); // Decay
        }
        // Buildings can attack if they have range/damage (e.g. Cannon)
        if (unit.damage > 0) {
           _handleCombat(unit, dt);
        }
        continue;
      }

      // Unit Logic
      _handleCombat(unit, dt);
    }
    
    // Clean dead
    state.units.removeWhere((u) => u.isDead);
    state.towers.removeWhere((t) => t.isDead);
  }

  void _tickTowers(double dt) {
    for (var tower in state.towers) {
      if (tower.isDead) continue;

      if (tower.attackCooldown > 0) {
        tower.attackCooldown -= dt;
      }

      if (tower.attackCooldown <= 0) {
        // Find Target
        BattleEntity? target;
        double closestDist = tower.range; // Start with max range
        
        final enemies = combatService.getAllEnemies(tower.side);
        for (var enemy in enemies) {
          if (enemy.isDead || enemy.spawnTimer > 0) continue;
          final dist = tower.position.distanceTo(enemy.position);
          if (dist <= closestDist) {
            closestDist = dist;
            target = enemy;
          }
        }

        if (target != null) {
          // Attack
          target.takeDamage(tower.damage);
          tower.attackCooldown = BattleTuning.debugNoCooldown ? 0.0 : tower.attackSpeed;
        }
      }
    }
  }

  void _tickSpells(double dt) {
    for (var spell in state.spells) {
      spell.elapsed += dt;
      spell.tickTimer += dt;
      
      if (spell.tickTimer >= spell.tickInterval) {
        spell.tickTimer = 0;
        
        // Apply Effect
        final enemies = combatService.getAllEnemies(spell.side);
        for (var enemy in enemies) {
          if (enemy.isDead) continue;
          if (enemy.position.distanceTo(spell.position) <= spell.radius) {
             // Apply Damage
             if (spell.damage > 0) {
               enemy.takeDamage(spell.damage);
               // Telemetry
               if (spell.side == BattleSide.player) {
                 state.telemetry.trackDamage(spell.cardId, spell.damage);
                 if (enemy.isDead && enemy is BattleTower) {
                   state.telemetry.trackTowerDestroyed();
                 }
               }
             }
             // Apply Status
             for (var effect in spell.statusEffects) {
               enemy.addStatus(StatusEffect(
                 type: effect.type,
                 value: effect.value,
                 duration: effect.duration,
               ));
             }
          }
        }
      }

      if (spell.elapsed >= spell.duration) {
        spell.finished = true;
      }
    }
    state.spells.removeWhere((s) => s.finished);
  }

  void _tickStatus(double dt) {
    // 1. Update Entities (Timers & Status)
    for (var unit in state.units) {
      if (!unit.isDead) unit.tick(dt);
    }
    for (var tower in state.towers) {
      if (!tower.isDead) tower.tick(dt);
    }

    // 2. Apply Auras
    for (var source in state.units) {
      if (source.isDead || source.auraRadius <= 0 || source.spawnTimer > 0) continue;

      final enemies = combatService.getAllEnemies(source.side);
      for (var enemy in enemies) {
        if (enemy.isDead || enemy.spawnTimer > 0) continue;
        if (source.position.distanceTo(enemy.position) <= source.auraRadius) {
          for (var effect in source.auraEffects) {
            // Apply/Refresh Aura Effect
            enemy.addStatus(StatusEffect(
              type: effect.type,
              value: effect.value,
              duration: 0.2,
            ));
          }
        }
      }
    }
  }

  void _handleCombat(BattleUnit unit, double dt) {
    if (unit.spawnTimer > 0) return; // Spawning
    
    // Update Targeting Timer
    if (unit.targetingTimer > 0) {
      unit.targetingTimer -= dt;
    }

    // 1. Validate Target
    if (unit.currentTarget != null && unit.currentTarget!.isDead) {
      unit.currentTarget = null;
    }

    // 2. Find Target if needed (Throttled)
    if (unit.currentTarget == null && unit.targetingTimer <= 0) {
      unit.currentTarget = TargetingSystem.findTarget(unit, state);
      unit.targetingTimer = 0.1; // Check every 100ms
    }

    final target = unit.currentTarget;

    // 3. Move or Attack
    if (target != null) {
      final dist = unit.position.distanceTo(target.position);
      if (dist <= unit.range) {
        // Attack via CombatService
        combatService.handleAttack(unit, target, dt);
      } else {
        // Move
        if (!unit.isBuilding && !unit.isStunned) {
           _moveTowards(unit, target.position, dt);
        }
      }
    } else {
      // No target? Move forward
      if (!unit.isBuilding && !unit.isStunned) {
         final forwardY = unit.side == BattleSide.player ? -15.0 : 15.0;
         _moveTowards(unit, Vector2(unit.position.x, forwardY), dt);
      }
    }
  }

  void _moveTowards(BattleUnit unit, Vector2 targetPos, double dt) {
    final dir = (targetPos - unit.position).normalized();
    unit.position += dir * unit.currentSpeed * dt;
  }

  void spawnUnit(String cardId, Vector2 worldPos, BattleSide side) {
    // Limit Units
    if (state.units.length >= 40) {
      // Optional: Log or feedback
      return; 
    }

    // Telemetry
    if (side == BattleSide.player && !state.isReplay) {
      state.telemetry.trackCardPlayed(cardId);
    }

    // Record Event
    if (!state.isReplay) {
      state.recordedEvents.add(ReplayEvent(
        timestamp: state.timeElapsed,
        side: side,
        cardId: cardId,
        x: worldPos.x,
        y: worldPos.y,
      ));
    }

    int level = 1;
    if (side == BattleSide.enemy && botController != null) {
       level = botController!.config.enemyCardLevel;
    } else if (side == BattleSide.player) {
       level = state.playerCardLevels[cardId] ?? 1;
    }

    final stats = BalanceRules.computeFinalStats(cardId, level);
    final def = cardCatalog.firstWhere((c) => c.cardId == cardId, orElse: () => CardDefinition(cardId: cardId, cost: 0, type: CardType.tropa, archetype: 'unknown', function: 'unknown'));
    
    if (def.type == CardType.feitico) {
      // Spell Configuration
      double radius = stats.radius ?? 2.5;
      double duration = stats.duration ?? 1.0;
      double damage = stats.damage.toDouble() * BattleTuning.globalStatsMultiplier;
      double tickInterval = 1.0;
      List<StatusEffect> effects = [];

      if (cardId.contains("poison")) {
        radius = 3.0;
        duration = 6.0;
        damage = 20; // DPS
        tickInterval = 1.0;
      } else if (cardId.contains("hailstorm")) {
        radius = 3.5;
        duration = 4.0;
        damage = 10;
        tickInterval = 1.0;
        effects.add(StatusEffect(type: StatusType.slow, value: 0.35, duration: 1.1));
      } else if (cardId.contains("lightning") || cardId.contains("cloud")) {
        radius = 2.5;
        duration = 0.1; // Instant
        damage = 200;
        tickInterval = 0.1;
        effects.add(StatusEffect(type: StatusType.stun, value: 1.0, duration: 0.35));
      } else if (cardId.contains("voodoo")) {
        radius = 3.0;
        duration = 4.0;
        damage = 0;
        tickInterval = 0.5;
        effects.add(StatusEffect(type: StatusType.damageTaken, value: 0.25, duration: 0.6));
      } else if (cardId.contains("spear") || cardId.contains("rain")) {
        radius = 3.0;
        duration = 1.2;
        damage = 30;
        tickInterval = 0.2;
      } else if (cardId.contains("hammer")) {
        radius = 1.5;
        duration = 0.1;
        damage = 300;
        tickInterval = 0.1;
      } else if (cardId.contains("loki") || cardId.contains("trickery")) {
        radius = 4.0;
        duration = 3.5;
        damage = 0;
        tickInterval = 0.5;
        effects.add(StatusEffect(type: StatusType.confusion, value: 1.0, duration: 0.6));
      }

      final spell = BattleSpell(
        id: '${cardId}_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(1000)}',
        cardId: cardId,
        side: side,
        position: worldPos,
        radius: radius,
        damage: damage,
        duration: duration,
        tickInterval: tickInterval,
        statusEffects: effects,
      );
      // Trigger immediately
      spell.tickTimer = tickInterval; 
      state.spells.add(spell);
    } else {
      // Determine Combat Properties
      AttackType attackType = AttackType.single;
      double aoeRadius = 0;
      List<StatusEffect> onHitEffects = [];
      double auraRadius = 0;
      List<StatusEffect> auraEffects = [];
      
      double damage = stats.damage.toDouble() * BattleTuning.globalStatsMultiplier;
      double range = stats.range;
      double hp = stats.hp.toDouble() * BattleTuning.globalStatsMultiplier;
      double attackSpeed = stats.attackSpeed;

      // Specific Logic (Temporary until Catalog is full)
      if (cardId.contains("bruiser") || cardId.contains("aoe")) {
        attackType = AttackType.aoe;
        aoeRadius = 1.5;
      }
      
      if (cardId.contains("control") || cardId.contains("ice")) {
        onHitEffects.add(StatusEffect(
          type: StatusType.slow,
          value: 0.15, // 15%
          duration: 1.2,
        ));
      }

      // Building Overrides
      if (def.type == CardType.construcao) {
        if (cardId.contains("wall")) {
          damage = 0; // Wall doesn't attack
          hp *= 1.5; // Beefy
        } else if (cardId.contains("siege")) {
          range = 10.0;
          damage *= 2.0;
          attackSpeed = 3.0;
          attackType = AttackType.aoe;
          aoeRadius = 1.5;
        } else if (cardId.contains("fire") || cardId.contains("catapult")) {
          onHitEffects.add(StatusEffect(
            type: StatusType.dot,
            value: 20, // 20 DPS
            duration: 3.0,
          ));
        } else if (cardId.contains("frost") || cardId.contains("gate")) {
          damage = 0;
          auraRadius = 4.0;
          auraEffects.add(StatusEffect(
            type: StatusType.slow,
            value: 0.25, // 25%
            duration: 0.2,
          ));
        } else if (cardId.contains("watchtower")) {
          range = 8.0;
        }
      }

      // Unit or Building
      final spawnDelay = BattleTuning.getSpawnDelay(def.cost);
      
      final unit = BattleUnit(
        id: '${cardId}_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(1000)}',
        side: side,
        cardId: cardId,
        position: worldPos,
        hp: hp,
        speed: def.type == CardType.construcao ? 0 : stats.speed * 2.0,
        range: range,
        damage: damage,
        attackSpeed: attackSpeed,
        isFlying: stats.targets == "air" || stats.effects.contains("flying"),
        isBuilding: def.type == CardType.construcao,
        lifetime: def.type == CardType.construcao ? 30.0 : 0,
        attackType: attackType,
        aoeRadius: aoeRadius,
        onHitEffects: onHitEffects,
        auraRadius: auraRadius,
        auraEffects: auraEffects,
      );
      unit.spawnTimer = spawnDelay;
      unit.maxSpawnTime = spawnDelay;
      unit.targetingTimer = Random().nextDouble() * 0.1; // Offset
      state.units.add(unit);
    }
  }
  void _processCommand(BattleCommand command) {
    if (command is PlayCardCommand) {
      spawnUnit(command.cardId, Vector2(command.x, command.y), command.side);
    }
  }
}
