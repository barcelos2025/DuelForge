
import 'dart:math';
import '../domain/entities/battle_stats.dart';
import 'card_catalog.dart';
import 'level_scaling.dart';

class BalanceRules {
  // ===========================================================================
  // BASE STATS BY COST
  // ===========================================================================

  static BattleStats getTroopBaseByCost(int cost) {
    switch (cost) {
      case 1: return const BattleStats(hp: 260, dps: 70, range: 3.5, speed: 1.15, attackSpeed: 1.0);
      case 2: return const BattleStats(hp: 420, dps: 95, range: 3.5, speed: 1.15, attackSpeed: 1.0);
      case 3: return const BattleStats(hp: 700, dps: 120, range: 4.5, speed: 1.00, attackSpeed: 1.0);
      case 4: return const BattleStats(hp: 1000, dps: 150, range: 4.5, speed: 1.00, attackSpeed: 1.0);
      case 5: return const BattleStats(hp: 1400, dps: 175, range: 5.5, speed: 1.00, attackSpeed: 1.0);
      case 6: return const BattleStats(hp: 1850, dps: 205, range: 5.5, speed: 0.85, attackSpeed: 1.2);
      case 7: return const BattleStats(hp: 2350, dps: 235, range: 6.5, speed: 0.85, attackSpeed: 1.2);
      case 8: return const BattleStats(hp: 2900, dps: 270, range: 6.5, speed: 0.85, attackSpeed: 1.3);
      case 9: return const BattleStats(hp: 3500, dps: 300, range: 7.5, speed: 0.85, attackSpeed: 1.3);
      case 10: return const BattleStats(hp: 4200, dps: 340, range: 7.5, speed: 0.85, attackSpeed: 1.4);
      default:
        // Fallback extrapolation
        if (cost < 1) return const BattleStats(hp: 200, dps: 50, range: 3.0, speed: 1.15);
        return const BattleStats(hp: 4500, dps: 360, range: 7.5, speed: 0.85);
    }
  }

  static BattleStats getBuildingBaseByCost(int cost) {
    switch (cost) {
      case 3: return const BattleStats(hp: 1600, dps: 85, speed: 0, attackSpeed: 1.0);
      case 4: return const BattleStats(hp: 2100, dps: 100, speed: 0, attackSpeed: 1.0);
      case 5: return const BattleStats(hp: 2700, dps: 120, speed: 0, attackSpeed: 1.0);
      case 6: return const BattleStats(hp: 3400, dps: 140, speed: 0, attackSpeed: 1.0);
      case 7: return const BattleStats(hp: 4200, dps: 155, speed: 0, attackSpeed: 1.0);
      case 8: return const BattleStats(hp: 5200, dps: 170, speed: 0, attackSpeed: 1.0);
      default:
        if (cost < 3) return const BattleStats(hp: 1200, dps: 70, speed: 0);
        return const BattleStats(hp: 5500, dps: 180, speed: 0);
    }
  }

  static BattleStats getSpellBaseByCost(int cost) {
    // Spells use 'damage' as total damage or base for calculation
    switch (cost) {
      case 2: return const BattleStats(damage: 260, radius: 1.8, speed: 0, range: 0);
      case 3: return const BattleStats(damage: 360, radius: 2.2, speed: 0, range: 0);
      case 4: return const BattleStats(damage: 480, radius: 2.6, speed: 0, range: 0);
      case 5: return const BattleStats(damage: 620, radius: 3.0, speed: 0, range: 0);
      case 6: return const BattleStats(damage: 760, radius: 3.2, speed: 0, range: 0);
      default:
        if (cost < 2) return const BattleStats(damage: 150, radius: 1.5, speed: 0);
        return const BattleStats(damage: 900, radius: 3.5, speed: 0);
    }
  }

  // ===========================================================================
  // ARCHETYPE MODIFIERS
  // ===========================================================================

  static BattleStats applyTroopArchetype(BattleStats base, String archetype) {
    // Clone base to avoid mutating consts (BattleStats is immutable via copyWith)
    double hpMult = 1.0;
    double dpsMult = 1.0;
    double rangeOverride = base.range;
    double speedOverride = base.speed;
    String targets = "ground";
    int spawnCount = 1;
    List<String> effects = [];

    switch (archetype) {
      case 'tank':
        hpMult = 1.65;
        dpsMult = 0.70;
        rangeOverride = 3.5; // Fixed melee/short range
        speedOverride = 0.85; // Slow
        targets = "ground";
        break;
      case 'bruiser':
        hpMult = 1.25;
        dpsMult = 1.00;
        rangeOverride = base.range.clamp(3.5, 4.5);
        speedOverride = 1.00; // Medium
        targets = "ground";
        break;
      case 'bruiser_aoe':
        hpMult = 1.20;
        dpsMult = 0.95;
        rangeOverride = 3.5;
        speedOverride = 1.00;
        targets = "ground";
        effects.add("aoe_1.8");
        break;
      case 'ranged_dps':
        hpMult = 0.70;
        dpsMult = 1.20;
        rangeOverride = max(base.range + 2.0, 5.5);
        speedOverride = 1.00;
        targets = "both"; // Usually hits air too
        break;
      case 'ranged_dps_control':
        hpMult = 0.70;
        dpsMult = 1.10;
        rangeOverride = base.range + 2.0;
        speedOverride = 1.00;
        targets = "ground"; // Specific rule
        effects.add("slow_15_1.2s");
        break;
      case 'ranged_dps_anti_tank':
        hpMult = 0.75;
        dpsMult = 1.10;
        rangeOverride = base.range + 2.0;
        speedOverride = 0.85;
        targets = "ground";
        effects.add("bonus_tank_20");
        break;
      case 'assassin':
        hpMult = 0.65;
        dpsMult = 1.35;
        rangeOverride = base.range.clamp(1.5, 3.5);
        speedOverride = 1.15; // Fast
        targets = "ground";
        break;
      case 'assassin_mobile':
        hpMult = 0.60;
        dpsMult = 1.25;
        speedOverride = 1.15;
        targets = "ground";
        effects.add("dash_6s");
        break;
      case 'assassin_anti_air_legendary':
        hpMult = 0.70;
        dpsMult = 1.30;
        rangeOverride = 3.5;
        speedOverride = 1.15;
        targets = "both";
        effects.add("flying");
        break;
      case 'support_caster':
        hpMult = 0.85;
        dpsMult = 0.75;
        rangeOverride = base.range + 1.5;
        targets = "both";
        effects.add("heal_buff");
        break;
      case 'support_buffer':
        hpMult = 0.80;
        dpsMult = 0.65;
        rangeOverride = base.range + 1.5;
        targets = "ground";
        effects.add("aura_atk_10");
        break;
      case 'swarm_anti_air':
        hpMult = 0.30;
        dpsMult = 0.55;
        spawnCount = 6;
        targets = "air"; // Specific
        speedOverride = 1.15;
        effects.add("flying");
        break;
      case 'bruiser_caster_mestre': // Odyn
        hpMult = 1.15;
        dpsMult = 1.10;
        rangeOverride = 6.5;
        speedOverride = 0.85;
        targets = "both";
        effects.add("ragnarok_pulse");
        break;
      default:
        // Default fallback
        break;
    }

    // Calculate final integer damage from DPS
    // Damage = DPS * AttackSpeed
    final finalDps = base.dps * dpsMult;
    final finalDamage = (finalDps * base.attackSpeed).round();
    final finalHp = (base.hp * hpMult).round();

    return base.copyWith(
      hp: finalHp,
      damage: finalDamage,
      dps: finalDps,
      range: rangeOverride,
      speed: speedOverride,
      targets: targets,
      spawnCount: spawnCount,
      effects: effects,
    );
  }

  static BattleStats applyBuildingArchetype(BattleStats base, String archetype) {
    double hpMult = 1.0;
    double dpsMult = 1.0;
    double rangeOverride = 0.0;
    String targets = "none";
    List<String> effects = [];
    double? radius;

    switch (archetype) {
      case 'defensive':
        hpMult = 1.15;
        dpsMult = 0.95;
        rangeOverride = 7.0;
        targets = "both";
        break;
      case 'defensive_ranged':
        hpMult = 1.05;
        dpsMult = 1.00;
        rangeOverride = 7.5;
        targets = "both";
        break;
      case 'defensive_control':
        hpMult = 1.20;
        dpsMult = 0.70;
        rangeOverride = 5.5;
        targets = "ground";
        effects.add("aura_slow_25");
        radius = 2.6;
        break;
      case 'wall':
        hpMult = 1.60;
        dpsMult = 0.0;
        rangeOverride = 0;
        targets = "none";
        break;
      case 'siege':
        hpMult = 0.90;
        dpsMult = 1.15;
        rangeOverride = 9.0;
        targets = "ground";
        radius = 2.0; // AoE
        effects.add("aoe_2.0");
        break;
      case 'siege_dot':
        hpMult = 0.85;
        dpsMult = 1.10;
        rangeOverride = 9.0;
        targets = "ground";
        radius = 2.4;
        effects.add("burn_dot_4s");
        break;
    }

    final finalDps = base.dps * dpsMult;
    final finalDamage = (finalDps * base.attackSpeed).round();
    final finalHp = (base.hp * hpMult).round();

    return base.copyWith(
      hp: finalHp,
      damage: finalDamage,
      dps: finalDps,
      range: rangeOverride,
      targets: targets,
      effects: effects,
      radius: radius,
    );
  }

  static BattleStats applySpellArchetype(BattleStats base, String archetype) {
    double damageMult = 1.0;
    double radiusOverride = base.radius ?? 2.0;
    double duration = 0.0;
    List<String> effects = [];

    switch (archetype) {
      case 'spell_burst':
        damageMult = 1.05;
        radiusOverride -= 0.4;
        duration = 0;
        break;
      case 'spell_burst_control':
        damageMult = 1.0;
        duration = 0;
        effects.add("stun_0.35s");
        break;
      case 'spell_dot_zone':
        damageMult = 1.0;
        radiusOverride += 0.2;
        duration = 6.0;
        break;
      case 'spell_control_slow':
        damageMult = 0.65;
        radiusOverride += 0.4;
        duration = 4.0;
        effects.add("slow_35");
        break;
      case 'spell_curse_debuff':
        damageMult = 0.35;
        duration = 4.0;
        effects.add("debuff_dmg_25");
        break;
      case 'spell_burst_aoe':
        damageMult = 0.90;
        radiusOverride += 0.2;
        duration = 1.2; // Multi-hit
        break;
      case 'spell_utility_control':
        damageMult = 0.45;
        duration = 3.5;
        effects.add("confuse");
        break;
    }

    final finalDamage = (base.damage * damageMult).round();
    // For spells, DPS is derived if duration > 0
    double finalDps = 0.0;
    if (duration > 0) {
      finalDps = finalDamage / duration;
    }

    return base.copyWith(
      damage: finalDamage,
      dps: finalDps,
      radius: radiusOverride,
      duration: duration,
      effects: effects,
      targets: "both", // Spells usually hit everything in area
    );
  }

  // ===========================================================================
  // MAIN COMPUTE FUNCTION
  // ===========================================================================

  static BattleStats computeFinalStats(String cardId, int level) {
    // 1. Find definition
    // 1. Find definition
    final def = cardCatalog.firstWhere(
      (c) => c.cardId == cardId,
      orElse: () => CardDefinition(
        cardId: cardId,
        cost: 3, // Default cost
        type: CardType.tropa, // Default type
        archetype: 'bruiser', // Default archetype
        function: 'unknown',
        tags: [],
      ),
    );

    // 2. Get Base
    BattleStats stats;
    if (def.type == CardType.tropa) {
      stats = getTroopBaseByCost(def.cost);
      stats = applyTroopArchetype(stats, def.archetype);
    } else if (def.type == CardType.construcao) {
      stats = getBuildingBaseByCost(def.cost);
      stats = applyBuildingArchetype(stats, def.archetype);
    } else {
      stats = getSpellBaseByCost(def.cost);
      stats = applySpellArchetype(stats, def.archetype);
    }

    // 3. Apply Level Scaling
    // Determine effective level based on rarity if we had rarity info in catalog.
    // The prompt says "multiplicadorNivel(n) = (1.08)^(n-1)".
    // Assuming 'level' passed here is the absolute level (1..15).
    // If we need to handle rarity offset, we need rarity in CardDefinition.
    // The previous prompt added tags, but not explicit rarity field in CardDefinition?
    // Checking CardDefinition... it has tags. I can infer rarity from tags or just use raw level.
    // Let's assume 'level' is the normalized level for stats.
    
    final multiplier = LevelScaling.levelMultiplier(level);
    
    final scaledHp = (stats.hp * multiplier).round();
    final scaledDamage = (stats.damage * multiplier).round();
    final scaledDps = stats.dps * multiplier;

    stats = stats.copyWith(
      hp: scaledHp,
      damage: scaledDamage,
      dps: scaledDps,
    );

    // 4. Validations (Anti-break)
    double finalRange = stats.range;
    int finalSpawnCount = stats.spawnCount;

    if (def.type == CardType.tropa && def.cost <= 4 && finalRange > 7.5) {
      finalRange = 7.5;
    }
    if (finalSpawnCount > 8) {
      finalSpawnCount = 8;
    }

    return stats.copyWith(
      range: finalRange,
      spawnCount: finalSpawnCount,
    );
  }

  static int computeUpgradeCost(String cardId, int currentLevel) {
    final def = cardCatalog.firstWhere(
      (c) => c.cardId == cardId,
      orElse: () => CardDefinition(
        cardId: cardId,
        cost: 0,
        type: CardType.tropa,
        archetype: 'unknown',
        function: 'unknown',
        tags: [],
      ),
    );

    double multiplier = 1.0;
    if (def.tags.contains('legendary')) {
      multiplier = 10.0;
    } else if (def.tags.contains('rare')) { // Assuming rare tag exists or will exist
      multiplier = 5.0;
    }

    // Base cost 50
    return (50 * multiplier * pow(1.5, currentLevel - 1)).round();
  }

  static void _validateStats(BattleStats stats, CardDefinition def) {
    // Deprecated, logic moved to computeFinalStats
  }
}
