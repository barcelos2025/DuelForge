import 'dart:convert';
import 'package:hive/hive.dart';
import '../entities/battle_objects.dart';

class MatchTelemetry {
  final String matchId;
  final DateTime timestamp;
  final List<String> playerDeck;
  
  // Metrics
  final Map<String, int> cardsPlayed = {};
  final Map<String, double> damageDealt = {};
  int towersDestroyed = 0;
  double matchDuration = 0;

  MatchTelemetry({
    required this.matchId,
    required this.playerDeck,
  }) : timestamp = DateTime.now();

  void trackCardPlayed(String cardId) {
    cardsPlayed[cardId] = (cardsPlayed[cardId] ?? 0) + 1;
  }

  void trackDamage(String cardId, double amount) {
    if (amount <= 0) return;
    damageDealt[cardId] = (damageDealt[cardId] ?? 0) + amount;
  }

  void trackTowerDestroyed() {
    towersDestroyed++;
  }

  void setDuration(double duration) {
    matchDuration = duration;
  }

  String getMvp() {
    if (damageDealt.isEmpty) return 'Nenhum';
    
    // Simple heuristic: Most damage
    // Could weight tower damage higher?
    var bestCard = '';
    var maxDmg = -1.0;

    damageDealt.forEach((cardId, dmg) {
      if (dmg > maxDmg) {
        maxDmg = dmg;
        bestCard = cardId;
      }
    });

    return bestCard;
  }

  Map<String, dynamic> toJson() {
    return {
      'matchId': matchId,
      'timestamp': timestamp.toIso8601String(),
      'playerDeck': playerDeck,
      'cardsPlayed': cardsPlayed,
      'damageDealt': damageDealt,
      'towersDestroyed': towersDestroyed,
      'matchDuration': matchDuration,
      'mvp': getMvp(),
    };
  }
}

class TelemetryService {
  static const String _boxName = 'match_telemetry';

  static Future<void> saveTelemetry(MatchTelemetry telemetry) async {
    final box = await Hive.openBox(_boxName);
    final jsonString = jsonEncode(telemetry.toJson());
    await box.add(jsonString);
    print('Telemetry saved: ${telemetry.matchId}');
  }

  static Future<List<Map<String, dynamic>>> getHistory() async {
    final box = await Hive.openBox(_boxName);
    return box.values.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }
}
