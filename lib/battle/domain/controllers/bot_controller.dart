import 'dart:math';
import 'package:flame/components.dart';
import '../entities/match_state.dart';
import '../entities/battle_objects.dart';
import '../ai/ai_core.dart';
import '../config/battle_field_config.dart';
import '../../data/card_catalog.dart';

// Mantendo para compatibilidade com MatchLoop
class BotPlay {
  final String cardId;
  final Vector2 position;
  BotPlay(this.cardId, this.position);
}

// Enums legados
enum BotProfile { aggro, control, siege, beatdown }
enum BotDifficulty { easy, normal, hard }

class BotDecks {
  static const List<String> aggro = [
    'corredor_gelo', 'corvos_odyn', 'martelo_trovao', 'arqueira_fiorde',
    'berserker_tundra', 'escudeiro_carvalho', 'cacadora_troll', 'chuva_granizo',
  ];
  static const List<String> control = [
    'portao_gelo', 'boneco_voodoo', 'chuva_lancas', 'torre_vigia',
    'cacador_baleia', 'brynhild', 'freyja', 'truque_loki',
  ];
  static const List<String> siege = [
    'catapulta', 'catapulta_fogo', 'barricada_troncos', 'escudeiro_carvalho',
    'cacadora_troll', 'martelo_trovao', 'arqueira_fiorde', 'tyr',
  ];
  static const List<String> beatdown = [
    'thor', 'bardo', 'freyja', 'axe_commander',
    'nuvem_raios', 'corvos_odyn', 'berserker_tundra', 'chuva_lancas',
  ];

  static List<String> getDeck(BotProfile profile) {
    switch (profile) {
      case BotProfile.aggro: return aggro;
      case BotProfile.control: return control;
      case BotProfile.siege: return siege;
      case BotProfile.beatdown: return beatdown;
    }
  }
}

class BotController {
  final MatchState matchState;
  final BotConfig config;
  late final Random _rng;
  
  double _reactionTimer = 0.0;
  double _apmTimer = 0.0;
  
  BotAction? _plannedAction;

  BotController(this.matchState, this.config, {int? seed}) {
    _rng = Random(seed ?? DateTime.now().millisecondsSinceEpoch);
    _reactionTimer = config.knobs.reactionTimeMs / 1000.0;
  }

  BotPlay? update(double dt) {
    _reactionTimer -= dt;
    _apmTimer -= dt;

    // 1. Limite de APM
    final apmInterval = 60.0 / config.knobs.apm;
    if (_apmTimer > 0) return null;

    // 2. Tempo de Reação
    if (_reactionTimer > 0) return null;

    // 3. Decisão
    if (_plannedAction != null) {
      final play = _executeAction(_plannedAction!);
      _plannedAction = null;
      
      if (play != null) {
        _apmTimer = apmInterval;
        _reactionTimer = (config.knobs.reactionTimeMs / 1000.0) * (0.8 + _rng.nextDouble() * 0.4);
        return play;
      } else {
        _reactionTimer = 0.5;
        return null;
      }
    }

    // 4. Consultar Policy
    final botElixir = matchState.enemyPower.currentPower;
    final hand = matchState.enemyDeck.getHand();
    
    // Passa os knobs para a policy
    final action = config.policy.decidir(matchState, botElixir, hand, config.knobs);

    if (action.wait) {
      _reactionTimer = 0.2; 
      return null;
    }

    // Ação decidida!
    // Erro de execução (Motor) - Adicional ao erro da policy
    // Se intentionalError for muito alto, pode errar o clique (simulado)
    if (_rng.nextDouble() < config.knobs.intentionalError * 0.5) {
       // Pequeno erro extra de posição
    }

    _plannedAction = action;
    _reactionTimer = 0.1; 
    
    return null;
  }

  BotPlay? _executeAction(BotAction action) {
    if (action.cardId == null || action.position == null) return null;

    final cost = _getCardCost(action.cardId!);
    
    if (matchState.enemyPower.consume(cost)) {
      matchState.enemyDeck.play(action.cardId!);
      return BotPlay(action.cardId!, _clampPos(action.position!));
    }
    return null;
  }

  int _getCardCost(String cardId) {
     final def = cardCatalog.firstWhere((c) => c.cardId == cardId, orElse: () => CardDefinition(cardId: cardId, cost: 3, type: CardType.tropa, archetype: '', function: '', tags: []));
     return def.cost;
  }

  Vector2 _clampPos(Vector2 pos) {
    double x = pos.x.clamp(-BattleFieldConfig.width/2 + 1, BattleFieldConfig.width/2 - 1);
    double y = pos.y.clamp(-BattleFieldConfig.height/2 + 1, BattleFieldConfig.height/2 - 1);
    if (y > 0) y = 0; 
    return Vector2(x, y);
  }
}
