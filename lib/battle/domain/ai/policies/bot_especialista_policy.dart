import 'package:flame/components.dart';
import '../ai_core.dart';
import '../../entities/match_state.dart';
import '../../entities/battle_objects.dart';
import 'bot_tatico_policy.dart';
import '../../difficulty/bot_skill_knobs.dart';
import '../../../data/card_catalog.dart';

class BotEspecialistaPolicy extends BotTaticoPolicy {
  @override
  String get name => 'Especialista_v2';

  @override
  BotAction decidir(MatchState state, double botElixir, List<String> hand, BotSkillKnobs knobs) {
    // 1. Gestão de Ciclo (Knob)
    // Se cycleControl for alto, segura elixir
    double reserveElixir = 3.0 * knobs.cycleControl;
    
    if (state.isOvertime || state.timeElapsed > 60) {
      reserveElixir = 1.0 * knobs.cycleControl;
    }

    bool emergency = false;
    for (final tower in state.towers) {
      if (tower.side == BattleSide.enemy && tower.hp < tower.maxHp * 0.5) {
         if (state.units.any((u) => u.side == BattleSide.player && u.position.distanceTo(tower.position) < 6)) {
           emergency = true;
           break;
         }
      }
    }

    if (emergency) reserveElixir = 0.0;

    // Chama a lógica tática (que já usa knobs para score e erro)
    final action = super.decidir(state, botElixir, hand, knobs);
    
    if (action.wait) return action;

    final cost = _getCardCost(action.cardId!);
    if (botElixir - cost < reserveElixir && !emergency) {
      return BotAction.waitAction;
    }

    return action;
  }

  int _getCardCost(String cardId) {
    final def = cardCatalog.firstWhere((c) => c.cardId == cardId, orElse: () => CardDefinition(cardId: cardId, cost: 3, type: CardType.tropa, archetype: '', function: '', tags: []));
    return def.cost;
  }
}
