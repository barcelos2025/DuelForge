
enum CardType { tropa, construcao, feitico }

class CardDefinition {
  final String cardId;
  final CardType type;
  final int cost;
  final String archetype;
  final String function;
  final List<String> tags;

  const CardDefinition({
    required this.cardId,
    required this.type,
    required this.cost,
    required this.archetype,
    required this.function,
    this.tags = const [],
  });
}

const List<CardDefinition> cardCatalog = [
  // 1) Axe Commander
  CardDefinition(
    cardId: 'df_card_axe_commander_v01.jpg',
    type: CardType.tropa,
    cost: 5,
    archetype: 'bruiser',
    function: 'Líder de pressão e frontline consistente',
    tags: ['melee', 'ground', 'fighter'],
  ),
  // 2) Bear Berserker
  CardDefinition(
    cardId: 'df_card_bear_berserker_v01.jpg',
    type: CardType.tropa,
    cost: 4,
    archetype: 'assassin',
    function: 'Burst melee para eliminar backline',
    tags: ['melee', 'ground', 'burst'],
  ),
  // 3) Brynhild
  CardDefinition(
    cardId: 'df_card_brynhild_v01.jpg',
    type: CardType.tropa,
    cost: 5,
    archetype: 'bruiser_aoe',
    function: 'Anti-horda e controle de lane',
    tags: ['melee', 'ground', 'aoe'],
  ),
  // 4) Catapult
  CardDefinition(
    cardId: 'df_card_catapult_v0.png',
    type: CardType.construcao,
    cost: 6,
    archetype: 'siege',
    function: 'Pressão longa na lane, dano por hit alto',
    tags: ['building', 'siege', 'ground', 'long_range'],
  ),
  // 5) Fire Catapult
  CardDefinition(
    cardId: 'df_card_fire_catapult_v01.png',
    type: CardType.construcao,
    cost: 7,
    archetype: 'siege_dot',
    function: 'Zona de dano e anti-horda com burn',
    tags: ['building', 'siege', 'ground', 'aoe', 'dot'],
  ),
  // 6) Freyja
  CardDefinition(
    cardId: 'df_card_freyja_v01.jpg',
    type: CardType.tropa,
    cost: 4,
    archetype: 'support_caster',
    function: 'Suporte (buff/escudo/cura leve)',
    tags: ['ranged', 'ground', 'support', 'healer'],
  ),
  // 7) Frost Gate
  CardDefinition(
    cardId: 'df_card_frost_gate_v01.jpg',
    type: CardType.construcao,
    cost: 4,
    archetype: 'defensive_control',
    function: 'Controle (slow em área) e segurar push',
    tags: ['building', 'defensive', 'control', 'slow'],
  ),
  // 8) Frost Ranger
  CardDefinition(
    cardId: 'df_card_frost_ranger_v01.jpg',
    type: CardType.tropa,
    cost: 3,
    archetype: 'ranged_dps_control',
    function: 'Ranged com slow leve para kite',
    tags: ['ranged', 'ground', 'control', 'slow'],
  ),
  // 9) Hailstorm
  CardDefinition(
    cardId: 'df_card_hailstorm_v01.png',
    type: CardType.feitico,
    cost: 4,
    archetype: 'spell_control_slow',
    function: 'Controle em área (slow) e dano leve',
    tags: ['spell', 'aoe', 'control', 'slow'],
  ),
  // 10) Ice Runner
  CardDefinition(
    cardId: 'df_card_ice_runner_v01.jpg',
    type: CardType.tropa,
    cost: 2,
    archetype: 'assassin_mobile',
    function: 'Ciclo rápido e pressão (dive)',
    tags: ['melee', 'ground', 'fast', 'cycle'],
  ),
  // 11) Lightning Cloud
  CardDefinition(
    cardId: 'df_card_lightning_cloud_v01.png',
    type: CardType.feitico,
    cost: 5,
    archetype: 'spell_burst_control',
    function: 'Burst + stun curto para virar troca',
    tags: ['spell', 'aoe', 'burst', 'stun'],
  ),
  // 12) Loki Trickery
  CardDefinition(
    cardId: 'df_card_loki_trickery_v01.jpg',
    type: CardType.feitico,
    cost: 4,
    archetype: 'spell_utility_control',
    function: 'Disrupt (confusão) para outplay',
    tags: ['spell', 'utility', 'control'],
  ),
  // 13) Odyn Master
  CardDefinition(
    cardId: 'df_card_odyn_master_v01.jpg',
    type: CardType.tropa,
    cost: 10,
    archetype: 'bruiser_caster_mestre',
    function: 'Condição de vitória late game',
    tags: ['melee', 'ranged', 'ground', 'legendary', 'win_condition'],
  ),
  // 14) Odyn Ravens
  CardDefinition(
    cardId: 'df_card_odyn_ravens_v01.jpg',
    type: CardType.tropa,
    cost: 2,
    archetype: 'swarm_anti_air',
    function: 'Anti-air barato e distração',
    tags: ['flying', 'swarm', 'cheap'],
  ),
  // 15) Palisade Wall
  CardDefinition(
    cardId: 'df_card_palisade_wall_v01.jpg',
    type: CardType.construcao,
    cost: 3,
    archetype: 'wall',
    function: 'Bloqueio e controle de caminho',
    tags: ['building', 'defensive', 'wall'],
  ),
  // 16) Poison
  CardDefinition(
    cardId: 'df_card_poison_v01.png',
    type: CardType.feitico,
    cost: 4,
    archetype: 'spell_dot_zone',
    function: 'Nega área e derrete suporte/horda',
    tags: ['spell', 'aoe', 'dot', 'zone'],
  ),
  // 17) Runic Spear Rain
  CardDefinition(
    cardId: 'df_card_runic_spear_rain_v01.jpg',
    type: CardType.feitico,
    cost: 4,
    archetype: 'spell_burst_aoe',
    function: 'Burst em área para limpar backline/horda',
    tags: ['spell', 'aoe', 'burst'],
  ),
  // 18) Shield Warrior
  CardDefinition(
    cardId: 'df_card_shield_warrior_v01.jpg',
    type: CardType.tropa,
    cost: 3,
    archetype: 'tank',
    function: 'Âncora barata para segurar lane',
    tags: ['melee', 'ground', 'tank', 'defensive'],
  ),
  // 19) Skald Bard
  CardDefinition(
    cardId: 'df_card_skald_bard_v01.jpg',
    type: CardType.tropa,
    cost: 3,
    archetype: 'support_buffer',
    function: 'Aura de buff para push',
    tags: ['ranged', 'ground', 'support', 'buffer'],
  ),
  // 20) Thor
  CardDefinition(
    cardId: 'df_card_thor_v01.jpg',
    type: CardType.tropa,
    cost: 6,
    archetype: 'bruiser',
    function: 'Frontline forte e burst em alvo',
    tags: ['melee', 'ground', 'tank', 'damage'],
  ),
  // 21) Thunder Hammer
  CardDefinition(
    cardId: 'df_card_thunder_hammer_v01.jpg',
    type: CardType.feitico,
    cost: 3,
    archetype: 'spell_burst',
    function: 'Impacto rápido em área pequena',
    tags: ['spell', 'aoe', 'burst', 'cheap'],
  ),
  // 22) Troll Huntress
  CardDefinition(
    cardId: 'df_card_troll_huntress_v01.jpg',
    type: CardType.tropa,
    cost: 4,
    archetype: 'ranged_dps',
    function: 'Backline DPS consistente',
    tags: ['ranged', 'ground', 'dps'],
  ),
  // 23) Tyr
  CardDefinition(
    cardId: 'df_card_tyr_v01.jpg',
    type: CardType.tropa,
    cost: 5,
    archetype: 'tank',
    function: 'Tanque principal com presença',
    tags: ['melee', 'ground', 'tank'],
  ),
  // 24) Ulf Legendary
  CardDefinition(
    cardId: 'df_card_ulf_legendary_v01.jpg',
    type: CardType.tropa,
    cost: 6,
    archetype: 'assassin',
    function: 'Pickoff lendário (alto risco/alto retorno)',
    tags: ['melee', 'ground', 'assassin', 'legendary'],
  ),
  // 25) Voodoo Doll
  CardDefinition(
    cardId: 'df_card_voodoo_doll_v01.png',
    type: CardType.feitico,
    cost: 3,
    archetype: 'spell_curse_debuff',
    function: 'Setup (amplifica dano)',
    tags: ['spell', 'debuff', 'curse'],
  ),
  // 26) Watchtower
  CardDefinition(
    cardId: 'df_card_watchtower_v01.jpg',
    type: CardType.construcao,
    cost: 4,
    archetype: 'defensive_ranged',
    function: 'Defesa e anti-air',
    tags: ['building', 'defensive', 'ranged', 'anti-air'],
  ),
  // 27) Whale Hunter
  CardDefinition(
    cardId: 'df_card_whale_hunter_v01.jpg',
    type: CardType.tropa,
    cost: 5,
    archetype: 'ranged_dps_anti_tank',
    function: 'Dano alto em alvo único vs tanques',
    tags: ['ranged', 'ground', 'dps', 'anti-tank'],
  ),
  // 28) Winged Demon Legendary
  CardDefinition(
    cardId: 'df_card_winged_demon_legendary_v01.png',
    type: CardType.tropa,
    cost: 7,
    archetype: 'assassin_anti_air_legendary',
    function: 'Ameaça aérea com burst',
    tags: ['flying', 'assassin', 'legendary', 'burst'],
  ),
];
