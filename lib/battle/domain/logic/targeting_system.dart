
import 'dart:math';
import 'package:flame/components.dart';
import '../entities/battle_objects.dart';
import '../entities/match_state.dart';
import '../config/battle_field_config.dart';

class TargetingSystem {
  static BattleEntity? findTarget(BattleUnit unit, MatchState state) {
    // Confusion Logic
    if (unit.isConfused) {
      final allUnits = <BattleEntity>[...state.units, ...state.towers];
      // Filter out self
      allUnits.remove(unit);
      if (allUnits.isNotEmpty) {
        return allUnits[Random().nextInt(allUnits.length)];
      }
      return null;
    }

    // 1. Check Aggro Range (Immediate threat)
    // If there is an enemy within aggroRange, attack it.
    // Priority: Unit > Building > Tower? Or just closest?
    // Usually closest within aggro.
    
    final enemies = _getAllEnemies(unit.side, state);
    
    BattleEntity? closestInAggro;
    double minDistAggro = unit.aggroRange;

    for (final enemy in enemies) {
      if (enemy.isDead) continue;
      final dist = unit.position.distanceTo(enemy.position);
      if (dist <= unit.aggroRange) {
        if (dist < minDistAggro) {
          minDistAggro = dist;
          closestInAggro = enemy;
        }
      }
    }

    if (closestInAggro != null) {
      return closestInAggro;
    }

    // 2. No immediate threat. Find objective to walk to.
    // "unidade mais próxima na lane; se não houver, atacar construção; se não houver, atacar torre mais próxima."
    
    // Determine Lane
    final isLeftLane = unit.position.x < 0;
    
    // Filter enemies by lane
    final laneEnemies = enemies.where((e) {
      if (e.isDead) return false;
      // Check if entity is in the same lane
      // For towers: Left Princess is Left, Right is Right. King is Both/Center.
      // For units: x < 0 is Left.
      
      if (e is BattleTower) {
        if (e.type == TowerType.king) return true; // King is always a valid target for both lanes
        if (isLeftLane && e.position.x < 0) return true;
        if (!isLeftLane && e.position.x > 0) return true;
        return false;
      }
      
      // Units/Buildings
      final eIsLeft = e.position.x < 0;
      return isLeftLane == eIsLeft;
    }).toList();

    // Sort by distance
    laneEnemies.sort((a, b) => 
      unit.position.distanceTo(a.position).compareTo(unit.position.distanceTo(b.position))
    );

    // Apply Priority: Unit > Building > Tower
    // Actually, the prompt says: "unidade mais próxima... se não houver, construção... se não houver, torre"
    // This implies we look for Units first.
    
    final units = laneEnemies.whereType<BattleUnit>().where((u) => !u.isBuilding).toList();
    if (units.isNotEmpty) return units.first;

    final buildings = laneEnemies.whereType<BattleUnit>().where((u) => u.isBuilding).toList();
    if (buildings.isNotEmpty) return buildings.first;

    final towers = laneEnemies.whereType<BattleTower>().toList();
    if (towers.isNotEmpty) return towers.first;

    // If nothing in lane (rare), return closest enemy anywhere
    if (enemies.isEmpty) return null;
    
    enemies.sort((a, b) => 
      unit.position.distanceTo(a.position).compareTo(unit.position.distanceTo(b.position))
    );
    return enemies.first;
  }

  static List<BattleEntity> _getAllEnemies(BattleSide mySide, MatchState state) {
    final enemySide = mySide == BattleSide.player ? BattleSide.enemy : BattleSide.player;
    
    final targets = <BattleEntity>[];
    
    // Units
    targets.addAll(state.units.where((u) => u.side == enemySide && !u.isDead));
    
    // Towers
    targets.addAll(state.towers.where((t) => t.side == enemySide && !t.isDead));
    
    return targets;
  }
}
