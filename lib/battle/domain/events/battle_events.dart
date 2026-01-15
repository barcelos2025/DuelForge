
import 'package:flame/components.dart';


abstract class BattleEvent {}

class UnitSpawnedEvent extends BattleEvent {
  final String cardId;
  final Side side; // Precisamos importar Side ou usar String/Enum local
  final Vector2 position; // Normalized 0..1

  UnitSpawnedEvent({required this.cardId, required this.side, required this.position});
}

// Side enum is defined in duelforge_game.dart usually, but domain shouldn't depend on presentation.
// Let's define Side in domain or use string.
// MatchState doesn't use Side yet.
// Let's define Side in a shared domain file or just here.
enum Side { player, enemy }
