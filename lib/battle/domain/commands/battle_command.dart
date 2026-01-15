
import '../entities/battle_objects.dart';

abstract class BattleCommand {
  final double timestamp;
  final BattleSide side;

  BattleCommand({required this.timestamp, required this.side});

  Map<String, dynamic> toJson();
}

class PlayCardCommand extends BattleCommand {
  final String cardId;
  final double x;
  final double y;

  PlayCardCommand({
    required super.timestamp,
    required super.side,
    required this.cardId,
    required this.x,
    required this.y,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': 'PlayCardCommand',
    'timestamp': timestamp,
    'side': side.toString(),
    'cardId': cardId,
    'x': x,
    'y': y,
  };

  factory PlayCardCommand.fromJson(Map<String, dynamic> json) {
    return PlayCardCommand(
      timestamp: json['timestamp'],
      side: json['side'] == 'BattleSide.player' ? BattleSide.player : BattleSide.enemy,
      cardId: json['cardId'],
      x: json['x'],
      y: json['y'],
    );
  }
}
