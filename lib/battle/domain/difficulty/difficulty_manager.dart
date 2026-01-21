import 'dart:math';
import 'package:flutter/foundation.dart';
import 'random_utils.dart';
import 'session_tracker.dart';
import 'bot_skill_knobs.dart';
import '../ai/ai_core.dart';
import '../ai/policies/bot_basico_policy.dart';
import '../ai/policies/bot_tatico_policy.dart';
import '../ai/policies/bot_especialista_policy.dart';

class DifficultyManager {
  static final DifficultyManager _instance = DifficultyManager._internal();
  factory DifficultyManager() => _instance;
  DifficultyManager._internal();

  BotConfig calculateMatchConfig({
    required int playerTrophies,
    required double playerWinRate,
    required double playerAvgCardLevel,
    required int consecutiveLosses,
    required int consecutiveWins,
    required String matchId,
  }) {
    // 1. Dificuldade Base
    double normArena = (playerTrophies / 3000.0).clamp(0.0, 1.0);
    double skillFactor = (playerWinRate - 0.5) * 0.4;
    
    double tiltAssist = 0.0;
    if (consecutiveLosses >= 2) {
      tiltAssist = (consecutiveLosses - 1) * 0.08;
      tiltAssist = tiltAssist.clamp(0.0, 0.30);
    }

    double winStreakPenalty = 0.0;
    if (consecutiveWins >= 4) {
      winStreakPenalty = (consecutiveWins - 3) * 0.05;
      winStreakPenalty = winStreakPenalty.clamp(0.0, 0.20);
    }

    double dBase = (0.7 * normArena) + (0.3 * (0.5 + skillFactor));
    dBase = dBase - tiltAssist + winStreakPenalty;
    
    if (normArena < 0.2) dBase -= 0.15;
    else if (normArena < 0.5) dBase -= 0.05;

    dBase = dBase.clamp(0.0, 1.0);

    // 2. Fadiga
    final session = SessionTracker();
    double fadigaTempo = RandomUtils.smoothStep(60, 150, session.sessionDurationMinutes.toDouble());
    double fadigaPartidas = RandomUtils.smoothStep(8, 25, session.matchesInSession.toDouble());
    double fadigaSessao = max(fadigaTempo, fadigaPartidas) * 0.12;
    
    double dSessao = (dBase + fadigaSessao).clamp(0.0, 1.0);

    // 3. Ruído
    double amplitude = RandomUtils.lerp(0.12, 0.04, normArena);
    int seed = RandomUtils.generateSeed('local_player', matchId);
    double ruido = RandomUtils.triangular(amplitude, seed: seed);

    // 4. Final
    double dFinal = (dSessao + ruido).clamp(0.0, 1.0);

    if (kDebugMode) {
      print('📊 Difficulty Calc: Base=${dBase.toStringAsFixed(2)} (Tilt:-$tiltAssist, Streak:+$winStreakPenalty)');
      print('   Session Fatigue: +${fadigaSessao.toStringAsFixed(2)} (${session.sessionDurationMinutes}m, ${session.matchesInSession} matches)');
      print('   Noise: ${ruido > 0 ? '+' : ''}${ruido.toStringAsFixed(3)}');
      print('   FINAL: ${dFinal.toStringAsFixed(2)}');
    }

    final knobs = _mapToKnobs(dFinal);

    // Selecionar Policy
    String id;
    AiPolicy policy;
    if (dFinal < 0.35) {
      id = 'bot_iniciante';
      policy = BotBasicoPolicy();
    } else if (dFinal < 0.75) {
      id = 'bot_intermediario';
      policy = BotTaticoPolicy();
    } else {
      id = 'bot_avancado';
      policy = BotEspecialistaPolicy();
    }

    return BotConfig(
      id: id,
      policy: policy,
      knobs: knobs,
      enemyCardLevel: playerAvgCardLevel.round().clamp(1, 15),
    );
  }

  BotSkillKnobs _mapToKnobs(double d) {
    double apm = RandomUtils.lerp(15, 60, d);
    double reactionTime = RandomUtils.lerp(1200, 300, d);
    double quality = RandomUtils.lerp(0.4, 0.95, d);
    double spell = RandomUtils.lerp(0.1, 0.9, d);
    double cycle = RandomUtils.smoothStep(0.4, 1.0, d) * 0.8;
    double planning = RandomUtils.smoothStep(0.3, 1.0, d) * 0.8;
    double error = RandomUtils.lerp(0.4, 0.02, d);
    double aggression = RandomUtils.lerp(0.3, 0.8, d);

    return BotSkillKnobs(
      apm: apm,
      reactionTimeMs: reactionTime,
      qualityTarget: quality,
      spellUsage: spell,
      cycleControl: cycle,
      shortTermPlanning: planning,
      intentionalError: error,
      laneAggression: aggression,
    );
  }
}
