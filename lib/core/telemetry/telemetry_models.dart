class TelemetryEvent {
  final String eventType;
  final Map<String, dynamic> payload;
  final DateTime timestamp;

  TelemetryEvent({
    required this.eventType,
    required this.payload,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'event_type': eventType,
      'payload': payload,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class MatchStartEvent extends TelemetryEvent {
  MatchStartEvent({
    required String matchId,
    required String opponentType, // 'bot' or 'player'
    required List<String> deckIds,
    required String arenaId,
  }) : super(
          eventType: 'match_start',
          payload: {
            'match_id': matchId,
            'opponent_type': opponentType,
            'deck_ids': deckIds,
            'arena_id': arenaId,
          },
        );
}

class MatchEndEvent extends TelemetryEvent {
  MatchEndEvent({
    required String matchId,
    required String result, // 'win', 'loss', 'draw'
    required int durationSeconds,
    required int trophiesDelta,
    required int crowns,
  }) : super(
          eventType: 'match_end',
          payload: {
            'match_id': matchId,
            'result': result,
            'duration_seconds': durationSeconds,
            'trophies_delta': trophiesDelta,
            'crowns': crowns,
          },
        );
}

class CardPlayedEvent extends TelemetryEvent {
  CardPlayedEvent({
    required String matchId,
    required String cardId,
    required int elixirCost,
    required int timeSinceStart,
  }) : super(
          eventType: 'card_played',
          payload: {
            'match_id': matchId,
            'card_id': cardId,
            'elixir_cost': elixirCost,
            'time_since_start': timeSinceStart,
          },
        );
}
