import 'package:flutter/foundation.dart';
import '../../entities/match_state.dart';
import '../ai_core.dart';

class AiDatasetLogger {
  static final List<String> _logs = [];

  static void logDecision(MatchState state, BotAction action, double elixir) {
    if (!kDebugMode) return; // Só em debug por enquanto

    // Formato CSV simples:
    // Timestamp, Elixir, PlayerUnitCount, EnemyUnitCount, ActionType, CardId, PosX, PosY
    final timestamp = state.timeElapsed.toStringAsFixed(2);
    final playerUnits = state.units.where((u) => u.side == BattleSide.player).length;
    final enemyUnits = state.units.where((u) => u.side == BattleSide.enemy).length;
    
    final actionType = action.wait ? 'WAIT' : 'PLAY';
    final cardId = action.cardId ?? '';
    final posX = action.position?.x.toStringAsFixed(1) ?? '';
    final posY = action.position?.y.toStringAsFixed(1) ?? '';

    final logLine = '$timestamp,$elixir,$playerUnits,$enemyUnits,$actionType,$cardId,$posX,$posY';
    _logs.add(logLine);
    
    // Em um app real, salvaríamos em arquivo ou enviaríamos para analytics
    // print('AI LOG: $logLine'); 
  }

  static void exportLogs() {
    print('--- AI DATASET EXPORT ---');
    print('Timestamp,Elixir,PlayerUnits,EnemyUnits,Action,Card,X,Y');
    for (final line in _logs) {
      print(line);
    }
    print('-------------------------');
    _logs.clear();
  }
}
