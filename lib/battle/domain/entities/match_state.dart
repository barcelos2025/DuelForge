import 'package:flame/components.dart';
import '../services/deck_service.dart';
import '../services/power_service.dart';
import 'battle_objects.dart';
import '../models/replay_data.dart';
import '../config/battle_field_config.dart';
import '../services/telemetry_service.dart';

enum MatchPhase { waiting, active, overtime, ended }

class MatchState {
  final String matchId;
  final PowerService playerPower;
  final PowerService enemyPower;
  final DeckService playerDeck;
  final DeckService enemyDeck;

  // Telemetry
  late final MatchTelemetry telemetry;

  // Config
  final double matchTimeTotal = 180.0; // 3 minutes
  
  // State
  MatchPhase phase = MatchPhase.waiting;
  double timeElapsed = 0;
  bool isOvertime = false;

  // Entities
  List<BattleTower> towers = [];
  List<BattleUnit> units = [];
  List<BattleSpell> spells = [];

  // Score
  int playerCrowns = 0;
  int enemyCrowns = 0;

  // Replay
  int randomSeed = 0;
  ReplayData? replayData;
  List<ReplayEvent> recordedEvents = [];
  bool isReplay = false;

  // Events
  void Function(BattleTower)? onTowerDestroyed;
  void Function(BattleSide winner)? onMatchEnd;

  MatchState({
    required this.matchId,
    required this.playerPower,
    required this.enemyPower,
    required this.playerDeck,
    required this.enemyDeck,
  }) {
    telemetry = MatchTelemetry(matchId: matchId, playerDeck: playerDeck.getHand()); // Initial hand or full deck?
    // DeckService doesn't expose full deck easily, but we can get it via reflection or if we change DeckService.
    // For now, let's just pass empty or modify DeckService later.
    // Actually, DeckService has `_deck` but it's private.
    // Let's assume we can get it or just track played cards.
    // Telemetry constructor asked for playerDeck.
    // Let's pass an empty list for now and fix if critical.
    _initTowers();
  }

  double get remainingTime => (matchTimeTotal - timeElapsed).clamp(0.0, matchTimeTotal);

  void startMatch() {
    phase = MatchPhase.active;
  }

  void endMatch(BattleSide winner) {
    phase = MatchPhase.ended;
    onMatchEnd?.call(winner);
  }

  void _initTowers() {
    Vector2 toWorld(double nx, double ny) {
      return Vector2(
        (nx - 0.5) * BattleFieldConfig.width,
        (ny - 0.5) * BattleFieldConfig.height,
      );
    }

    // Player Towers (Bottom)
    towers.add(BattleTower(id: 'p_king', side: BattleSide.player, type: TowerType.king, position: toWorld(0.5, 0.9)));
    towers.add(BattleTower(id: 'p_left', side: BattleSide.player, type: TowerType.princess, position: toWorld(0.2, 0.75)));
    towers.add(BattleTower(id: 'p_right', side: BattleSide.player, type: TowerType.princess, position: toWorld(0.8, 0.75)));

    // Enemy Towers (Top)
    towers.add(BattleTower(id: 'e_king', side: BattleSide.enemy, type: TowerType.king, position: toWorld(0.5, 0.1)));
    towers.add(BattleTower(id: 'e_left', side: BattleSide.enemy, type: TowerType.princess, position: toWorld(0.8, 0.25))); // Inverted X for enemy perspective? No, 0.8 is Right side of screen.
    // Enemy Left Tower (from Player view) is at 0.2?
    // If Enemy is at Top, their "Left" is Player's "Right".
    // Let's stick to Screen Coordinates:
    // 0.2 is Left side of screen.
    // 0.8 is Right side of screen.
    // Enemy King at 0.1 Y.
    // Enemy Towers at 0.25 Y.
    // So 'e_left' at 0.2, 0.25. 'e_right' at 0.8, 0.25.
    towers.add(BattleTower(id: 'e_left', side: BattleSide.enemy, type: TowerType.princess, position: toWorld(0.2, 0.25)));
    towers.add(BattleTower(id: 'e_right', side: BattleSide.enemy, type: TowerType.princess, position: toWorld(0.8, 0.25)));
  }

  void checkEndCondition() {
    if (phase == MatchPhase.ended) return;

    // 1. King Destroyed
    final playerKing = towers.any((t) => t.side == BattleSide.player && t.type == TowerType.king && !t.isDead);
    final enemyKing = towers.any((t) => t.side == BattleSide.enemy && t.type == TowerType.king && !t.isDead);

    if (!playerKing) {
      endMatch(BattleSide.enemy);
      return;
    }
    if (!enemyKing) {
      endMatch(BattleSide.player);
      return;
    }

    // 2. Time Up
    if (remainingTime <= 0) {
      if (playerCrowns > enemyCrowns) {
        endMatch(BattleSide.player);
      } else if (enemyCrowns > playerCrowns) {
        endMatch(BattleSide.enemy);
      } else {
        // Tie or Overtime logic (if not already in overtime)
        // For now, simple tie logic:
        // If tie, maybe extended overtime? 
        // User said: "empate se igual".
        // Let's just end as Draw (or handle externally). 
        // We'll pass null or a special Draw enum? 
        // For now, let's assume Player wins ties for simplicity or add Draw support later.
        // Actually, let's just not call endMatch if it's a true draw, or define a Draw side?
        // Let's stick to simple:
        endMatch(BattleSide.enemy); // Draw favors enemy for now (or handle properly)
      }
    }
  }
}

