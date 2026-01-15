import 'dart:math';
import '../models/carta.dart';

class CardStats {
  int hp;
  int dano;
  double dps;
  double alcance;
  double velocidade; // 1.15 (rápido), 1.0 (médio), 0.85 (lento)
  double? raio;
  double? duracao;
  double? slow;
  String? alvo; // "terra", "ar", "ambos"
  int quantidadeSpawn;
  String? efeito;
  bool aoe;

  CardStats({
    this.hp = 0,
    this.dano = 0,
    this.dps = 0.0,
    this.alcance = 0.0,
    this.velocidade = 1.0,
    this.raio,
    this.duracao,
    this.slow,
    this.alvo,
    this.quantidadeSpawn = 1,
    this.efeito,
    this.aoe = false,
  });
}

class CardStatsCalculator {
  // ========================================================
  // B) BASE NUMÉRICA POR CUSTO (para TROPA)
  // ========================================================
  
  static CardStats obterBaseTropaPorCusto(int custoPoder) {
    switch (custoPoder) {
      case 1: return CardStats(hp: 260, dps: 70, alcance: 3.5, velocidade: 1.15);
      case 2: return CardStats(hp: 420, dps: 95, alcance: 3.5, velocidade: 1.15);
      case 3: return CardStats(hp: 700, dps: 120, alcance: 4.5, velocidade: 1.00);
      case 4: return CardStats(hp: 1000, dps: 150, alcance: 4.5, velocidade: 1.00);
      case 5: return CardStats(hp: 1400, dps: 175, alcance: 5.5, velocidade: 1.00);
      case 6: return CardStats(hp: 1850, dps: 205, alcance: 5.5, velocidade: 0.85);
      case 7: return CardStats(hp: 2350, dps: 235, alcance: 6.5, velocidade: 0.85);
      case 8: return CardStats(hp: 2900, dps: 270, alcance: 6.5, velocidade: 0.85);
      case 9: return CardStats(hp: 3500, dps: 300, alcance: 7.5, velocidade: 0.85);
      case 10: return CardStats(hp: 4200, dps: 340, alcance: 7.5, velocidade: 0.85);
      default: 
        if (custoPoder < 1) return CardStats(hp: 200, dps: 50, alcance: 3.0, velocidade: 1.15);
        return CardStats(hp: 4500, dps: 360, alcance: 7.5, velocidade: 0.85);
    }
  }

  static CardStats obterBaseConstrucaoPorCusto(int custoPoder) {
    switch (custoPoder) {
      case 3: return CardStats(hp: 1600, dps: 85);
      case 4: return CardStats(hp: 2100, dps: 100);
      case 5: return CardStats(hp: 2700, dps: 120);
      case 6: return CardStats(hp: 3400, dps: 140);
      case 7: return CardStats(hp: 4200, dps: 155);
      case 8: return CardStats(hp: 5200, dps: 170);
      default:
        if (custoPoder < 3) return CardStats(hp: 1200, dps: 70);
        return CardStats(hp: 5500, dps: 180);
    }
  }

  static Map<String, double> obterBaseFeiticoPorCusto(int custoPoder) {
    switch (custoPoder) {
      case 2: return {'danoBase': 260, 'raio': 1.8};
      case 3: return {'danoBase': 360, 'raio': 2.2};
      case 4: return {'danoBase': 480, 'raio': 2.6};
      case 5: return {'danoBase': 620, 'raio': 3.0};
      case 6: return {'danoBase': 760, 'raio': 3.2};
      default:
        if (custoPoder < 2) return {'danoBase': 150, 'raio': 1.5};
        return {'danoBase': 900, 'raio': 3.5};
    }
  }

  // ========================================================
  // C) MULTIPLICADORES POR ARQUÉTIPO (TROPA)
  // ========================================================

  static CardStats aplicarArquetipoTropa(CardStats base, String arquetipo) {
    final stats = CardStats(
      hp: base.hp,
      dps: base.dps,
      alcance: base.alcance,
      velocidade: base.velocidade,
      quantidadeSpawn: base.quantidadeSpawn,
    );

    switch (arquetipo.toLowerCase()) {
      case 'tank':
        stats.hp = (stats.hp * 1.65).round();
        stats.dps *= 0.70;
        stats.alcance = 3.5;
        stats.velocidade = 0.85; // lento
        stats.alvo = "terra";
        break;
      case 'bruiser':
        stats.hp = (stats.hp * 1.25).round();
        stats.dps *= 1.00;
        stats.alcance = stats.alcance.clamp(3.5, 4.5);
        stats.velocidade = 1.00; // medio
        stats.alvo = "terra";
        break;
      case 'bruiser_aoe':
        stats.hp = (stats.hp * 1.20).round();
        stats.dps *= 0.95;
        stats.aoe = true;
        stats.raio = 1.8;
        stats.alcance = 3.5;
        stats.velocidade = 1.00; // medio
        stats.alvo = "terra";
        break;
      case 'ranged_dps':
        stats.hp = (stats.hp * 0.70).round();
        stats.dps *= 1.20;
        stats.alcance = max(stats.alcance + 2.0, 5.5);
        stats.velocidade = 1.00; // medio
        stats.alvo = "terra";
        break;
      case 'ranged_dps_control':
        stats.hp = (stats.hp * 0.70).round();
        stats.dps *= 1.10;
        stats.alcance += 2.0;
        stats.velocidade = 1.00; // medio
        stats.alvo = "terra";
        stats.slow = 0.15; // 15%
        // duracao slow 1.2s on hit (implementar no engine)
        break;
      case 'ranged_dps_anti_tank':
        stats.hp = (stats.hp * 0.75).round();
        stats.dps *= 1.10;
        stats.alcance += 2.0;
        stats.velocidade = 0.85; // lento
        stats.alvo = "terra";
        stats.efeito = "bonus_tank_20pct";
        break;
      case 'assassin':
        stats.hp = (stats.hp * 0.65).round();
        stats.dps *= 1.35;
        stats.alcance = stats.alcance.clamp(1.5, 3.5);
        stats.velocidade = 1.15; // rapido
        stats.alvo = "terra";
        break;
      case 'assassin_mobile':
        stats.hp = (stats.hp * 0.60).round();
        stats.dps *= 1.25;
        stats.velocidade = 1.15; // rapido
        stats.efeito = "dash_cooldown_6s";
        break;
      case 'assassin_anti_air_legendary':
        stats.hp = (stats.hp * 0.70).round();
        stats.dps *= 1.30;
        stats.alvo = "ambos";
        stats.alcance = 3.5;
        stats.velocidade = 1.15; // rapido
        // unidade aérea
        break;
      case 'support_caster':
        stats.hp = (stats.hp * 0.85).round();
        stats.dps *= 0.75;
        stats.alcance += 1.5;
        stats.alvo = "ambos";
        stats.efeito = "buff_shield_heal";
        break;
      case 'support_buffer':
        stats.hp = (stats.hp * 0.80).round();
        stats.dps *= 0.65;
        stats.alcance += 1.5;
        stats.efeito = "aura_buff_atk_10pct";
        break;
      case 'swarm_anti_air':
        stats.hp = (stats.hp * 0.30).round();
        stats.dps *= 0.55;
        stats.quantidadeSpawn = 6;
        stats.alvo = "ar"; // ou ambos com dps -10%
        stats.velocidade = 1.15; // rapido
        break;
      case 'bruiser_caster_mestre': // Odyn
        stats.hp = (stats.hp * 1.15).round(); 
        stats.dps *= 1.10;
        stats.alcance = 6.5;
        stats.alvo = "ambos";
        stats.velocidade = 0.85; // Lento
        stats.efeito = "vulneravel_controle,ragnarok_pulse";
        break;
    }
    
    stats.dano = stats.dps.round();
    return stats;
  }

  // ========================================================
  // D) CONSTRUÇÕES (BASE + REGRAS)
  // ========================================================

  static CardStats aplicarArquetipoConstrucao(CardStats base, String arquetipo) {
    final stats = CardStats(
      hp: base.hp,
      dps: base.dps,
      velocidade: 0,
    );

    switch (arquetipo.toLowerCase()) {
      case 'defensive':
        stats.hp = (stats.hp * 1.15).round();
        stats.dps *= 0.95;
        stats.alcance = 7.0; // 6.5~7.5
        stats.alvo = "ambos";
        break;
      case 'defensive_ranged':
        stats.hp = (stats.hp * 1.05).round();
        stats.dps *= 1.00;
        stats.alcance = 7.5;
        stats.alvo = "ambos";
        break;
      case 'defensive_control':
        stats.hp = (stats.hp * 1.20).round();
        stats.dps *= 0.70;
        stats.alcance = 5.5;
        stats.alvo = "terra";
        stats.efeito = "aura_slow_25pct";
        stats.raio = 2.6; // Raio da aura
        break;
      case 'wall':
        stats.hp = (stats.hp * 1.60).round();
        stats.dps = 0;
        stats.alcance = 0;
        stats.alvo = "nenhum";
        break;
      case 'siege':
        stats.hp = (stats.hp * 0.90).round();
        stats.dps *= 1.15;
        stats.alcance = 9.0;
        stats.alvo = "terra";
        stats.aoe = true;
        stats.raio = 2.0;
        break;
      case 'siege_dot':
        stats.hp = (stats.hp * 0.85).round();
        stats.dps *= 1.10;
        stats.alcance = 9.0;
        stats.alvo = "terra";
        stats.aoe = true;
        stats.raio = 2.4;
        stats.efeito = "burn_dot_4s";
        break;
    }
    
    stats.dano = stats.dps.round();
    return stats;
  }

  // ========================================================
  // E) FEITIÇOS (BASE + TIPOS)
  // ========================================================

  static CardStats aplicarArquetipoFeitico(Map<String, double> base, String arquetipo) {
    final stats = CardStats(velocidade: 0, alcance: 0);
    double danoBase = base['danoBase']!;
    double raio = base['raio']!;
    double danoTotal = danoBase;
    
    switch (arquetipo.toLowerCase()) {
      case 'spell_burst':
        stats.duracao = 0;
        stats.raio = raio - 0.4; // Thunder hammer rule
        danoTotal = danoBase * 1.05;
        break;
      case 'spell_burst_control':
        stats.duracao = 0;
        stats.efeito = "stun_0.35s";
        break;
      case 'spell_dot_zone':
        stats.duracao = 6.0;
        stats.raio = raio + 0.2;
        // danoTotal = danoBase
        break;
      case 'spell_control_slow':
        danoTotal = danoBase * 0.65;
        stats.duracao = 4.0;
        stats.slow = 0.35;
        stats.raio = raio + 0.4;
        break;
      case 'spell_curse_debuff':
        danoTotal = danoBase * 0.35;
        stats.duracao = 4.0;
        stats.efeito = "debuff_recebe_25pct_dano";
        break;
      case 'spell_burst_aoe':
        danoTotal = danoBase * 0.90;
        stats.duracao = 1.2; // multi-hit
        stats.raio = raio + 0.2;
        break;
      case 'spell_utility_control':
        danoTotal = danoBase * 0.45;
        stats.duracao = 3.5;
        stats.efeito = "confusao";
        break;
    }

    stats.raio = raio; // Base já ajustada no switch acima se necessário? 
    // Wait, switch modifies local vars, need to assign back to stats or use logic correctly.
    // Correcting logic:
    
    switch (arquetipo.toLowerCase()) {
      case 'spell_burst':
        stats.raio = raio - 0.4;
        danoTotal = danoBase * 1.05;
        stats.duracao = 0;
        break;
      case 'spell_burst_control':
        stats.raio = raio;
        danoTotal = danoBase;
        stats.duracao = 0;
        stats.efeito = "stun_0.35s";
        break;
      case 'spell_dot_zone':
        stats.raio = raio + 0.2;
        danoTotal = danoBase;
        stats.duracao = 6.0;
        break;
      case 'spell_control_slow':
        stats.raio = raio + 0.4;
        danoTotal = danoBase * 0.65;
        stats.duracao = 4.0;
        stats.slow = 0.35;
        break;
      case 'spell_curse_debuff':
        stats.raio = raio;
        danoTotal = danoBase * 0.35;
        stats.duracao = 4.0;
        stats.efeito = "debuff_recebe_25pct_dano";
        break;
      case 'spell_burst_aoe':
        stats.raio = raio + 0.2;
        danoTotal = danoBase * 0.90;
        stats.duracao = 1.2;
        break;
      case 'spell_utility_control':
        stats.raio = raio;
        danoTotal = danoBase * 0.45;
        stats.duracao = 3.5;
        stats.efeito = "confusao";
        break;
      default:
        stats.raio = raio;
    }

    stats.dano = danoTotal.round();
    if (stats.duracao != null && stats.duracao! > 0) {
      stats.dps = danoTotal / stats.duracao!;
    }

    return stats;
  }

  // ========================================================
  // F) DISTRIBUIÇÃO FINAL DAS 28 CARTAS
  // ========================================================

  static final Map<String, Map<String, dynamic>> _cardDefinitions = {
    'df_card_axe_commander_v01.jpg': {'tipo': TipoCarta.tropa, 'custo': 5, 'arquetipo': 'bruiser'},
    'df_card_bear_berserker_v01.jpg': {'tipo': TipoCarta.tropa, 'custo': 4, 'arquetipo': 'assassin'},
    'df_card_brynhild_v01.jpg': {'tipo': TipoCarta.tropa, 'custo': 5, 'arquetipo': 'bruiser_aoe'},
    'df_card_catapult_v0.png': {'tipo': TipoCarta.construcao, 'custo': 6, 'arquetipo': 'siege'},
    'df_card_fire_catapult_v01.png': {'tipo': TipoCarta.construcao, 'custo': 7, 'arquetipo': 'siege_dot'},
    'df_card_freyja_v01.jpg': {'tipo': TipoCarta.tropa, 'custo': 4, 'arquetipo': 'support_caster'},
    'df_card_frost_gate_v01.jpg': {'tipo': TipoCarta.construcao, 'custo': 4, 'arquetipo': 'defensive_control'},
    'df_card_frost_ranger_v01.jpg': {'tipo': TipoCarta.tropa, 'custo': 3, 'arquetipo': 'ranged_dps_control'},
    'df_card_hailstorm_v01.png': {'tipo': TipoCarta.feitico, 'custo': 4, 'arquetipo': 'spell_control_slow'},
    'df_card_ice_runner_v01.jpg': {'tipo': TipoCarta.tropa, 'custo': 2, 'arquetipo': 'assassin_mobile'},
    'df_card_lightning_cloud_v01.png': {'tipo': TipoCarta.feitico, 'custo': 5, 'arquetipo': 'spell_burst_control'},
    'df_card_loki_trickery_v01.jpg': {'tipo': TipoCarta.feitico, 'custo': 4, 'arquetipo': 'spell_utility_control'},
    'df_card_odyn_master_v01.jpg': {'tipo': TipoCarta.tropa, 'custo': 10, 'arquetipo': 'bruiser_caster_mestre'},
    'df_card_odyn_ravens_v01.jpg': {'tipo': TipoCarta.tropa, 'custo': 2, 'arquetipo': 'swarm_anti_air'},
    'df_card_palisade_wall_v01.jpg': {'tipo': TipoCarta.construcao, 'custo': 3, 'arquetipo': 'wall'},
    'df_card_poison_v01.png': {'tipo': TipoCarta.feitico, 'custo': 4, 'arquetipo': 'spell_dot_zone'},
    'df_card_runic_spear_rain_v01.jpg': {'tipo': TipoCarta.feitico, 'custo': 4, 'arquetipo': 'spell_burst_aoe'},
    'df_card_shield_warrior_v01.jpg': {'tipo': TipoCarta.tropa, 'custo': 3, 'arquetipo': 'tank'},
    'df_card_skald_bard_v01.jpg': {'tipo': TipoCarta.tropa, 'custo': 3, 'arquetipo': 'support_buffer'},
    'df_card_thor_v01.jpg': {'tipo': TipoCarta.tropa, 'custo': 6, 'arquetipo': 'bruiser'},
    'df_card_thunder_hammer_v01.jpg': {'tipo': TipoCarta.feitico, 'custo': 3, 'arquetipo': 'spell_burst'},
    'df_card_troll_huntress_v01.jpg': {'tipo': TipoCarta.tropa, 'custo': 4, 'arquetipo': 'ranged_dps'},
    'df_card_tyr_v01.jpg': {'tipo': TipoCarta.tropa, 'custo': 5, 'arquetipo': 'tank'},
    'df_card_ulf_legendary_v01.jpg': {'tipo': TipoCarta.tropa, 'custo': 6, 'arquetipo': 'assassin'},
    'df_card_voodoo_doll_v01.png': {'tipo': TipoCarta.feitico, 'custo': 3, 'arquetipo': 'spell_curse_debuff'},
    'df_card_watchtower_v01.jpg': {'tipo': TipoCarta.construcao, 'custo': 4, 'arquetipo': 'defensive_ranged'},
    'df_card_whale_hunter_v01.jpg': {'tipo': TipoCarta.tropa, 'custo': 5, 'arquetipo': 'ranged_dps_anti_tank'},
    'df_card_winged_demon_legendary_v0*': {'tipo': TipoCarta.tropa, 'custo': 7, 'arquetipo': 'assassin_anti_air_legendary'},
  };

  static CardStats statsPorNivel(String cardId, int nivel, String raridade) {
    // Busca definição
    final def = _cardDefinitions[cardId];
    if (def == null) {
      // Fallback genérico se ID não bater
      return calcularAtributos(Carta(id: cardId, nome: 'Unknown', tipo: TipoCarta.tropa, raridade: raridade, custo: 3, poder: 3), nivel);
    }

    final tipo = def['tipo'] as TipoCarta;
    final custo = def['custo'] as int;
    final arquetipo = def['arquetipo'] as String;

    CardStats stats;

    if (tipo == TipoCarta.tropa) {
      final base = obterBaseTropaPorCusto(custo);
      stats = aplicarArquetipoTropa(base, arquetipo);
    } else if (tipo == TipoCarta.construcao) {
      final base = obterBaseConstrucaoPorCusto(custo);
      stats = aplicarArquetipoConstrucao(base, arquetipo);
    } else {
      final base = obterBaseFeiticoPorCusto(custo);
      stats = aplicarArquetipoFeitico(base, arquetipo);
    }

    // Aplica Nível
    stats = aplicarNivel(stats, nivel, raridade);

    // Valida Limites
    validarLimites(stats, cardId, custo, tipo);

    return stats;
  }

  // Mantido para compatibilidade com código anterior, mas redireciona para lógica nova se possível
  static CardStats calcularAtributos(Carta carta, int nivel) {
    // Tenta usar o ID da carta para pegar a definição precisa
    // Se o ID da carta bater com as chaves do map, ótimo.
    // O ID da carta no JSON deve ser o nome do arquivo de imagem ou algo mapeável.
    // Assumindo que carta.id ou carta.imagePath pode ser usado.
    
    String key = carta.imagePath?.split('/').last ?? carta.id;
    // Tenta achar chave que contenha o nome (pois o ID pode variar)
    String? matchedKey;
    for (var k in _cardDefinitions.keys) {
      if (key.contains(k.replaceAll('*', ''))) { // Trata wildcard simples
        matchedKey = k;
        break;
      }
    }

    if (matchedKey != null) {
      return statsPorNivel(matchedKey, nivel, carta.raridade);
    }

    // Fallback para lógica genérica anterior se não achar na tabela
    // ... (lógica genérica anterior simplificada ou mantida)
    return CardStats(hp: 100, dano: 10); // Placeholder fallback
  }

  // ========================================================
  // 6) ESCALA POR NÍVEL E RARIDADE
  // ========================================================

  static double multiplicadorNivel(int nivel) {
    return 1.00 * pow(1.08, nivel - 1);
  }

  static int obterNivelReal(int nivelCarta, String raridade) {
    int bonus = 0;
    switch (raridade.toLowerCase()) {
      case 'comum': bonus = 0; break;
      case 'rara': bonus = 2; break;
      case 'epica': bonus = 5; break;
      case 'lendaria': bonus = 8; break;
      case 'mestre': bonus = 10; break;
    }
    return nivelCarta + bonus;
  }

  static CardStats aplicarNivel(CardStats stats, int nivel, String raridade) {
    int nivelEfetivo = obterNivelReal(nivel, raridade);
    double mult = multiplicadorNivel(nivelEfetivo);

    return CardStats(
      hp: (stats.hp * mult).round(),
      dano: (stats.dano * mult).round(),
      dps: stats.dps * mult,
      alcance: stats.alcance,
      velocidade: stats.velocidade,
      raio: stats.raio,
      duracao: stats.duracao,
      slow: stats.slow,
      alvo: stats.alvo,
      quantidadeSpawn: stats.quantidadeSpawn,
      efeito: stats.efeito,
      aoe: stats.aoe,
    );
  }

  static void validarLimites(CardStats stats, String cardId, int custo, TipoCarta tipo) {
    // - Nenhuma tropa custo <=4 pode ter alcance >7.5
    if (tipo == TipoCarta.tropa && custo <= 4 && stats.alcance > 7.5) {
      stats.alcance = 7.5;
    }
    
    // - Slow máximo 40%
    if (stats.slow != null && stats.slow! > 0.40) {
      stats.slow = 0.40;
    }

    // - Swarm max 8
    if (stats.quantidadeSpawn > 8) {
      stats.quantidadeSpawn = 8;
    }
  }

  static int custoPoderPorCarta(String cardId) {
     for (var entry in _cardDefinitions.entries) {
       if (cardId.contains(entry.key.replaceAll('*', ''))) {
         return entry.value['custo'] as int;
       }
     }
     return 3; // Default
  }
}
