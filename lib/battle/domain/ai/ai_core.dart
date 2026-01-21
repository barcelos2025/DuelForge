import 'package:flame/components.dart';
import '../entities/match_state.dart';
import '../difficulty/bot_skill_knobs.dart';

/// Define a ação que o Bot decidiu tomar.
class BotAction {
  final String? cardId;
  final Vector2? position;
  final bool wait; // Se true, o bot decidiu esperar (acumular elixir)
  final String reason; // Para debug/log

  const BotAction({
    this.cardId,
    this.position,
    this.wait = false,
    this.reason = '',
  });

  static const waitAction = BotAction(wait: true, reason: 'Waiting for elixir/opportunity');
}

/// Interface abstrata para qualquer cérebro de bot (Heurístico ou ML).
abstract class AiPolicy {
  /// Recebe o estado atual e decide a próxima ação.
  BotAction decidir(MatchState state, double botElixir, List<String> hand, BotSkillKnobs knobs);
  
  /// Nome da política para logs (ex: "Basico_v1", "Tatico_v2")
  String get name;
}

/// Configuração de dificuldade e comportamento do bot.
class BotConfig {
  final String id;
  final AiPolicy policy;
  final BotSkillKnobs knobs;
  final int enemyCardLevel; // Nível das cartas do bot

  const BotConfig({
    required this.id,
    required this.policy,
    required this.knobs,
    this.enemyCardLevel = 1,
  });
}
