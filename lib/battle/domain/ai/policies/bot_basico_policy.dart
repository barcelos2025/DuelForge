import 'dart:math';
import 'package:flame/components.dart';
import '../ai_core.dart';
import '../../entities/match_state.dart';
import '../../entities/battle_objects.dart';
import '../../config/battle_field_config.dart';
import '../../../data/card_catalog.dart';
import '../../difficulty/bot_skill_knobs.dart';

class BotBasicoPolicy implements AiPolicy {
  final Random _rng = Random();

  @override
  String get name => 'Basico_v2';

  @override
  BotAction decidir(MatchState state, double botElixir, List<String> hand, BotSkillKnobs knobs) {
    // 1. Verificar se tem elixir suficiente
    final affordableCards = hand.where((id) {
      final cost = _getCardCost(id);
      return cost <= botElixir;
    }).toList();

    if (affordableCards.isEmpty) {
      return BotAction.waitAction;
    }

    // 2. Defesa Básica (Reativo)
    // Usa knobs.reactionTimeMs implicitamente via BotController, mas aqui podemos simular "não ver" a ameaça
    // Se qualityTarget for baixo, pode ignorar defesa
    if (_rng.nextDouble() < knobs.qualityTarget) {
      final towers = state.towers.where((t) => t.side == BattleSide.enemy && !t.isDead);
      for (final tower in towers) {
        final attackers = state.units.where((u) => 
          u.side == BattleSide.player && 
          !u.isDead &&
          u.position.distanceTo(tower.position) < 8.0
        );

        if (attackers.isNotEmpty) {
          final cardToPlay = affordableCards.first;
          final defensivePos = tower.position + Vector2(0, 3); 
          
          return BotAction(
            cardId: cardToPlay,
            position: _fuzzPosition(defensivePos, knobs.intentionalError),
            reason: 'Defending tower',
          );
        }
      }
    }

    // 3. Ataque Aleatório
    final cardToPlay = affordableCards[_rng.nextInt(affordableCards.length)];
    
    // Lane Aggression: Se alto, foca numa lane. Se baixo, espalha.
    double laneX;
    if (_rng.nextDouble() < knobs.laneAggression) {
      // Foca na lane com menos vida da torre inimiga? Ou aleatória consistente?
      // Básico é aleatório.
      laneX = _rng.nextBool() ? -5.0 : 5.0;
    } else {
      laneX = _rng.nextBool() ? -5.0 : 5.0;
    }
    
    final spawnY = -12.0;

    return BotAction(
      cardId: cardToPlay,
      position: _fuzzPosition(Vector2(laneX, spawnY), knobs.intentionalError),
      reason: 'Random attack',
    );
  }

  int _getCardCost(String cardId) {
    final def = cardCatalog.firstWhere((c) => c.cardId == cardId, orElse: () => CardDefinition(cardId: cardId, cost: 3, type: CardType.tropa, archetype: '', function: '', tags: []));
    return def.cost;
  }

  Vector2 _fuzzPosition(Vector2 pos, double errorRate) {
    // Erro em tiles (ex: 2.0 tiles de erro se errorRate for 1.0)
    final error = errorRate * 2.0;
    return pos + Vector2((_rng.nextDouble() - 0.5) * error, (_rng.nextDouble() - 0.5) * error);
  }
}
