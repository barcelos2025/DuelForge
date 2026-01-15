
import 'dart:convert';
import '../entities/match_state.dart';
import '../entities/battle_objects.dart';

class MatchSerializer {
  static Map<String, dynamic> serialize(MatchState state) {
    return {
      'matchId': state.matchId,
      'timeElapsed': state.timeElapsed,
      'phase': state.phase.toString(),
      'playerPower': state.playerPower.currentPower,
      'enemyPower': state.enemyPower.currentPower,
      'units': state.units.map((u) => _serializeUnit(u)).toList(),
      'towers': state.towers.map((t) => _serializeTower(t)).toList(),
      // Add other fields as needed
    };
  }

  static Map<String, dynamic> _serializeUnit(BattleUnit unit) {
    return {
      'id': unit.id,
      'cardId': unit.cardId,
      'side': unit.side.toString(),
      'x': unit.position.x,
      'y': unit.position.y,
      'hp': unit.hp,
      // Add other dynamic fields like status effects
    };
  }

  static Map<String, dynamic> _serializeTower(BattleTower tower) {
    return {
      'id': tower.id,
      'side': tower.side.toString(),
      'type': tower.type.toString(),
      'x': tower.position.x,
      'y': tower.position.y,
      'hp': tower.hp,
    };
  }

  // Deserialize would be complex because we need to reconstruct objects and link references (targets).
  // For now, serialization is enough for "snapshot" viewing or debugging.
}
