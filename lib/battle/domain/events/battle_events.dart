
import 'package:flame/components.dart';

abstract class BattleEvent {}

class UnitSpawnedEvent extends BattleEvent {
  final String cardId;
  final Side side;
  final Vector2 position; // Normalized 0..1

  UnitSpawnedEvent({required this.cardId, required this.side, required this.position});
}

class MatchEndEvent extends BattleEvent {
  final String winner; // 'player' or 'enemy'
  
  MatchEndEvent({required this.winner});
}

enum Side { player, enemy }
