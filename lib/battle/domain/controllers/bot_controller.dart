
import 'dart:math';
import 'package:flame/components.dart';
import '../entities/match_state.dart';
import '../entities/battle_objects.dart';
import '../../data/card_catalog.dart';
import '../config/battle_field_config.dart';

class BotPlay {
  final String cardId;
  final Vector2 position;
  BotPlay(this.cardId, this.position);
}

enum BotProfile { aggro, control, siege, beatdown }
enum BotDifficulty { easy, normal, hard }

class BotConfig {
  final BotProfile profile;
  final BotDifficulty difficulty;
  final int seed;

  BotConfig({
    required this.profile,
    required this.difficulty,
    required this.seed,
  });
}

class BotDecks {
  static const List<String> aggro = [
    'df_card_ice_runner_v01.jpg',
    'df_card_odyn_ravens_v01.jpg',
    'df_card_thunder_hammer_v01.jpg',
    'df_card_frost_ranger_v01.jpg',
    'df_card_bear_berserker_v01.jpg',
    'df_card_shield_warrior_v01.jpg',
    'df_card_troll_huntress_v01.jpg',
    'df_card_hailstorm_v01.png',
  ];

  static const List<String> control = [
    'df_card_frost_gate_v01.jpg',
    'df_card_voodoo_doll_v01.png',
    'df_card_runic_spear_rain_v01.jpg',
    'df_card_watchtower_v01.jpg',
    'df_card_whale_hunter_v01.jpg',
    'df_card_brynhild_v01.jpg',
    'df_card_freyja_v01.jpg',
    'df_card_loki_trickery_v01.jpg',
  ];

  static const List<String> siege = [
    'df_card_catapult_v0.png',
    'df_card_fire_catapult_v01.png',
    'df_card_palisade_wall_v01.jpg',
    'df_card_shield_warrior_v01.jpg',
    'df_card_troll_huntress_v01.jpg',
    'df_card_thunder_hammer_v01.jpg',
    'df_card_frost_ranger_v01.jpg',
    'df_card_tyr_v01.jpg',
  ];

  static const List<String> beatdown = [
    'df_card_thor_v01.jpg',
    'df_card_skald_bard_v01.jpg',
    'df_card_freyja_v01.jpg',
    'df_card_axe_commander_v01.jpg',
    'df_card_lightning_cloud_v01.png',
    'df_card_odyn_ravens_v01.jpg',
    'df_card_bear_berserker_v01.jpg',
    'df_card_runic_spear_rain_v01.jpg',
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
  
  double _decisionTimer = 0.0;
  late final double _decisionInterval;
  late final double _errorChance;

  BotController(this.matchState, this.config) {
    _rng = Random(config.seed);
    
    // Configure Difficulty
    switch (config.difficulty) {
      case BotDifficulty.easy:
        _decisionInterval = 2.0;
        _errorChance = 0.3;
        break;
      case BotDifficulty.normal:
        _decisionInterval = 0.6;
        _errorChance = 0.1;
        break;
      case BotDifficulty.hard:
        _decisionInterval = 0.4;
        _errorChance = 0.0;
        break;
    }
  }

  BotPlay? update(double dt) {
    _decisionTimer += dt;
    if (_decisionTimer < _decisionInterval) return null;
    _decisionTimer = 0;

    // 1. Check Resources
    final power = matchState.enemyPower.currentPower;
    if (power < 2) return null; // Wait for some elixir

    // 2. Analyze Threats (Player Units)
    final threats = matchState.units
        .where((u) => u.side == BattleSide.player && !u.isDead)
        .toList();

    // Sort by threat level (proximity to base + cost/power)
    // Threats to Enemy are Player units with high Y (approaching 15)
    threats.sort((a, b) => b.position.y.compareTo(a.position.y));

    final hand = matchState.enemyDeck.getHand();
    
    // 3. Decide Action
    
    // A. Defend against immediate threats (crossed bridge)
    // Bridge is roughly Y=0.
    final immediateThreats = threats.where((t) => t.position.y > 0).toList();
    
    if (immediateThreats.isNotEmpty) {
      // Pick biggest threat
      final target = immediateThreats.first;
      
      // Find counter
      final play = _findCounter(target, hand, power);
      if (play != null) return play;
    }

    // B. If no immediate threat, maybe build push or counter-push
    // Profile Logic
    double investmentThreshold = 8.0;
    if (config.profile == BotProfile.aggro) investmentThreshold = 4.0; // Push fast
    if (config.profile == BotProfile.control) investmentThreshold = 9.0; // Wait for max
    
    if (power > investmentThreshold) {
      return _playInvestment(hand, power);
    }

    return null;
  }

  BotPlay? _findCounter(BattleUnit target, List<String> hand, double power) {
    // Error Chance (Misplay)
    if (_rng.nextDouble() < _errorChance) {
      // Pick random affordable card
      final affordable = hand.where((id) => matchState.enemyDeck.getCardCost(id) <= power).toList();
      if (affordable.isNotEmpty) {
        final randomCard = affordable[_rng.nextInt(affordable.length)];
        return BotPlay(randomCard, _clampPos(target.position + Vector2(0, 5))); // Bad placement
      }
      return null;
    }

    // Analyze Target
    bool isSwarm = target.cardId.contains('swarm') || target.cardId.contains('ravens'); // Heuristic
    bool isTank = target.hp > 1000;
    bool isAir = target.isFlying;
    
    // Filter affordable cards
    final affordable = hand.where((id) => matchState.enemyDeck.getCardCost(id) <= power).toList();
    if (affordable.isEmpty) return null;

    String? bestCard;
    Vector2? pos;

    for (var cardId in affordable) {
      final def = cardCatalog.firstWhere((c) => c.cardId == cardId);
      
      // Logic
      if (isSwarm) {
        if (def.tags.contains('aoe') || def.tags.contains('spell')) {
          bestCard = cardId;
          // Spell on top, Unit nearby
          if (def.type == CardType.feitico) {
            pos = target.position;
          } else {
            pos = Vector2(target.position.x, target.position.y + 3); 
          }
          break;
        }
      } else if (isTank) {
        if (def.tags.contains('dps') || def.tags.contains('anti-tank') || def.tags.contains('debuff')) {
          bestCard = cardId;
          pos = Vector2(0, 8); // Center pull?
          break;
        }
      } else if (isAir) {
        if (def.tags.contains('anti-air') || def.tags.contains('ranged')) {
          bestCard = cardId;
          pos = Vector2(target.position.x, 10);
          break;
        }
      }
    }

    // Fallback: Just play something cheap to distract
    if (bestCard == null) {
      bestCard = affordable.first;
      pos = Vector2(0, 10);
    }

    // Refine Position
    if (pos == null) {
       // Default defensive pos
       pos = Vector2(target.position.x, 8);
    }
    
    // Execute
    if (matchState.enemyPower.consume(matchState.enemyDeck.getCardCost(bestCard))) {
       matchState.enemyDeck.play(bestCard);
       return BotPlay(bestCard, _clampPos(pos));
    }
    
    return null;
  }

  BotPlay? _playInvestment(List<String> hand, double power) {
    // Play tank or spawner in back
    final affordable = hand.where((id) => matchState.enemyDeck.getCardCost(id) <= power).toList();
    if (affordable.isEmpty) return null;

    // Prefer Tank or Building
    String? cardId;
    try {
      if (config.profile == BotProfile.siege) {
         cardId = affordable.firstWhere((id) {
           final def = cardCatalog.firstWhere((c) => c.cardId == id);
           return def.archetype.contains('siege');
         });
      } else if (config.profile == BotProfile.beatdown) {
         cardId = affordable.firstWhere((id) {
           final def = cardCatalog.firstWhere((c) => c.cardId == id);
           return def.tags.contains('tank');
         });
      } else {
         // Aggro/Control: Play cycle or investment
         cardId = affordable.firstWhere((id) {
            final def = cardCatalog.firstWhere((c) => c.cardId == id);
            return def.cost <= 4; // Cheap cycle
         });
      }
    } catch (_) {
      cardId = affordable[_rng.nextInt(affordable.length)];
    }

    if (cardId != null) {
       if (matchState.enemyPower.consume(matchState.enemyDeck.getCardCost(cardId))) {
         matchState.enemyDeck.play(cardId);
         // Play behind King or Princess
         double x = _rng.nextBool() ? 4.0 : -4.0;
         double y = 13.0; // Behind King (King is at 12?)
         // Map limits: Height ~15.
         return BotPlay(cardId, _clampPos(Vector2(x, 12)));
       }
    }
    return null;
  }

  Vector2 _clampPos(Vector2 pos) {
    // Clamp to field
    double x = pos.x.clamp(-BattleFieldConfig.width/2 + 1, BattleFieldConfig.width/2 - 1);
    double y = pos.y.clamp(-BattleFieldConfig.height/2 + 1, BattleFieldConfig.height/2 - 1);
    
    // Enemy side constraint?
    // Enemy can only deploy on their side (Y > 0) unless a tower is down (not implemented yet).
    // Let's assume Y > 0 for now.
    if (y < 0) y = 0; // Bridge
    
    return Vector2(x, y);
  }
}
