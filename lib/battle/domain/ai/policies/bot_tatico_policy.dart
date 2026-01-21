import 'dart:math';
import 'package:flame/components.dart';
import '../ai_core.dart';
import '../../entities/match_state.dart';
import '../../entities/battle_objects.dart';
import '../../../data/card_catalog.dart';
import '../../difficulty/bot_skill_knobs.dart';

class BotTaticoPolicy implements AiPolicy {
  final Random _rng = Random();

  @override
  String get name => 'Tatico_v2';

  @override
  BotAction decidir(MatchState state, double botElixir, List<String> hand, BotSkillKnobs knobs) {
    if (botElixir < 2.0) return BotAction.waitAction;

    final affordableCards = hand.where((id) => _getCardCost(id) <= botElixir).toList();
    if (affordableCards.isEmpty) return BotAction.waitAction;

    BotAction? bestAction;
    double bestScore = -double.infinity;

    final positions = [
      Vector2(-5, -10), // Defesa Esq
      Vector2(5, -10),  // Defesa Dir
      Vector2(-5, -2),  // Ataque Esq
      Vector2(5, -2),   // Ataque Dir
    ];

    for (final cardId in affordableCards) {
      for (final pos in positions) {
        final score = _evaluateAction(state, cardId, pos, botElixir, knobs);
        if (score > bestScore) {
          bestScore = score;
          bestAction = BotAction(cardId: cardId, position: pos, reason: 'Score: ${score.toStringAsFixed(1)}');
        }
      }
    }

    if (bestScore > 5.0) {
      // Aplica erro proposital na posição final
      if (bestAction != null) {
        return BotAction(
          cardId: bestAction.cardId,
          position: _fuzzPosition(bestAction.position!, knobs.intentionalError),
          reason: bestAction.reason,
        );
      }
    }

    if (botElixir > 9.0 && bestAction != null) {
      return bestAction;
    }

    return BotAction.waitAction;
  }

  double _evaluateAction(MatchState state, String cardId, Vector2 pos, double currentElixir, BotSkillKnobs knobs) {
    double score = 0.0;
    final cost = _getCardCost(cardId);
    final def = _getCardDef(cardId);

    // 1. Análise de Ameaça (Defesa)
    double threatLevel = 0.0;
    for (final unit in state.units) {
      if (unit.side == BattleSide.player && !unit.isDead) {
        final dist = unit.position.distanceTo(pos);
        if (dist < 6.0) {
          if (pos.y < -5) {
            threatLevel += (unit.hp / 100) + (unit.damage / 20);
          }
        }
      }
    }

    if (threatLevel > 0) {
      // Defesa
      if (def.type == CardType.construcao) {
        score += threatLevel * 1.5;
      } else if (def.type == CardType.tropa) {
        score += threatLevel * 1.2;
      }
      score -= (cost - threatLevel).clamp(0, 10) * 0.5;
    } else {
      // Ataque
      if (pos.y > -5) {
        score += 2.0; 
        if (currentElixir > 7) score += 3.0;
        if (def.type == CardType.tropa && def.cost < 3) score -= 2.0;
        
        // Lane Aggression: Valoriza atacar a mesma lane
        // (Simplificado: assume lane esquerda < 0)
        // Se laneAggression for alto, tenta focar.
        // TODO: Implementar memória de lane focada.
      }
    }

    // 2. Sinergia
    for (final unit in state.units) {
      if (unit.side == BattleSide.enemy && !unit.isDead) {
        final dist = unit.position.distanceTo(pos);
        if (dist < 4.0) {
           score += 1.0;
        }
      }
    }

    // 3. Uso de Feitiço (Knob)
    if (def.type == CardType.feitico) {
      // Se spellUsage for baixo, penaliza uso de feitiço (faz ele errar ou não usar)
      if (knobs.spellUsage < 0.5) {
        score -= 5.0; // Evita usar
      } else {
        // Se alto, valoriza se tiver muitos alvos
        // (Lógica simplificada)
      }
    }

    // 4. Aleatoriedade Tática (Humanização)
    // Se qualityTarget for baixo, adiciona mais ruído ao score (escolhas piores)
    double noise = (1.0 - knobs.qualityTarget) * 5.0;
    score += (_rng.nextDouble() * noise);

    return score;
  }

  int _getCardCost(String cardId) => _getCardDef(cardId).cost;

  CardDefinition _getCardDef(String cardId) {
    return cardCatalog.firstWhere(
      (c) => c.cardId == cardId, 
      orElse: () => CardDefinition(cardId: cardId, cost: 3, type: CardType.tropa, archetype: '', function: '', tags: [])
    );
  }

  Vector2 _fuzzPosition(Vector2 pos, double errorRate) {
    final error = errorRate * 2.0;
    return pos + Vector2((_rng.nextDouble() - 0.5) * error, (_rng.nextDouble() - 0.5) * error);
  }
}
