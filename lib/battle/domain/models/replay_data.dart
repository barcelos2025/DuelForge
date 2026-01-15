
import 'package:flame/components.dart';
import '../entities/battle_objects.dart';

class ReplayEvent {
  final double timestamp;
  final BattleSide side;
  final String cardId;
  final double x;
  final double y;

  ReplayEvent({
    required this.timestamp,
    required this.side,
    required this.cardId,
    required this.x,
    required this.y,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp,
    'side': side.toString(),
    'cardId': cardId,
    'x': x,
    'y': y,
  };

  factory ReplayEvent.fromJson(Map<String, dynamic> json) {
    return ReplayEvent(
      timestamp: json['timestamp'],
      side: json['side'] == 'BattleSide.player' ? BattleSide.player : BattleSide.enemy,
      cardId: json['cardId'],
      x: json['x'],
      y: json['y'],
    );
  }
}

class ReplayData {
  final int seed;
  final List<ReplayEvent> events;

  ReplayData({required this.seed, required this.events});

  Map<String, dynamic> toJson() => {
    'seed': seed,
    'events': events.map((e) => e.toJson()).toList(),
  };

  factory ReplayData.fromJson(Map<String, dynamic> json) {
    return ReplayData(
      seed: json['seed'],
      events: (json['events'] as List).map((e) => ReplayEvent.fromJson(e)).toList(),
    );
  }
}
