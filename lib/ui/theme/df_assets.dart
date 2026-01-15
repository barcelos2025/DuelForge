/// DuelForge UI Assets
/// 
/// Classe centralizada para acesso aos assets de UI do jogo.
/// Todos os assets seguem a estética nórdica premium com cartoon 3D.
class DFAssets {
  // ==================== ITEMS ====================
  
  /// Moedas de Ouro
  static const String goldCoin = 'assets/ui/items/df_item_gold_coin_v01.png';
  static const String goldStack = 'assets/ui/items/df_item_gold_stack_v01.png';
  
  /// Cristais Rúnicos
  static const String runeCrystalSmall = 'assets/ui/items/df_item_rune_crystal_small_v01.png';
  static const String runeCrystalMedium = 'assets/ui/items/df_item_rune_crystal_medium_v01.png';
  static const String runeCrystalLarge = 'assets/ui/items/df_item_rune_crystal_large_v01.png';
  
  /// Gemas Premium
  static const String gemSingle = 'assets/ui/items/df_item_gem_premium_single_v01.png';
  static const String gemBag = 'assets/ui/items/df_item_gem_premium_bag_v01.png';
  static const String gemStack = 'assets/ui/items/df_item_gem_premium_stack_v01.png';
  
  /// Fragmentos de Carta (por raridade)
  static const String shardsCommon = 'assets/ui/items/df_item_card_shards_common_v01.png';
  static const String shardsRare = 'assets/ui/items/df_item_card_shards_rare_v01.png';
  static const String shardsEpic = 'assets/ui/items/df_item_card_shards_epic_v01.png';
  static const String shardsLegendary = 'assets/ui/items/df_item_card_shards_legendary_v01.png';
  static const String shardsMaster = 'assets/ui/items/df_item_card_shards_master_v01.png';
  
  /// Orbes de Energia Rúnica
  static const String runeOrbEmpty = 'assets/ui/items/df_item_rune_orb_empty_v01.png';
  static const String runeOrbHalf = 'assets/ui/items/df_item_rune_orb_half_v01.png';
  static const String runeOrbFull = 'assets/ui/items/df_item_rune_orb_full_v01.png';
  
  /// Itens de Upgrade
  static const String upgradeScroll = 'assets/ui/items/df_item_upgrade_scroll_v01.png';
  static const String forgeHammer = 'assets/ui/items/df_item_forge_hammer_v01.png';
  
  // ==================== POTIONS ====================
  
  static const String potionHeal = 'assets/ui/potions/df_potion_heal_v01.png';
  static const String potionRage = 'assets/ui/potions/df_potion_rage_v01.png';
  static const String potionFrost = 'assets/ui/potions/df_potion_frost_v01.png';
  // TODO: Adicionar quando disponíveis:
  // static const String potionPoison = 'assets/ui/potions/df_potion_poison_v01.png';
  // static const String potionLightning = 'assets/ui/potions/df_potion_lightning_v01.png';
  // static const String potionLegendary = 'assets/ui/potions/df_potion_legendary_v01.png';
  
  // ==================== CHESTS ====================
  static const String chestWooden = 'assets/ui/chests/wooden.png';
  static const String chestGold = 'assets/ui/chests/gold.png';
  
  // ==================== ICONS ====================
  static const String iconGold = 'assets/ui/icons/gold.png';
  static const String iconGem = 'assets/ui/icons/gem.png';
  static const String iconElixir = 'assets/ui/icons/elixir.png';
  static const String iconSettings = 'assets/ui/icons/settings.png';
  
  // ==================== BUTTONS ====================
  static const String btnPrimary = 'assets/ui/buttons/primary.png';
  static const String btnSecondary = 'assets/ui/buttons/secondary.png';
  static const String btnClose = 'assets/ui/buttons/close.png';
  
  // ==================== BADGES ====================
  // TODO: Adicionar quando disponíveis
  
  // ==================== VFX ====================
  // TODO: Adicionar quando disponíveis
  
  // ==================== HELPERS ====================
  
  /// Retorna o asset de fragmentos de carta baseado na raridade
  static String getCardShardsByRarity(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
      case 'comum':
        return shardsCommon;
      case 'rare':
      case 'raro':
        return shardsRare;
      case 'epic':
      case 'épico':
      case 'epico':
        return shardsEpic;
      case 'legendary':
      case 'lendário':
      case 'lendario':
        return shardsLegendary;
      case 'master':
      case 'mestre':
        return shardsMaster;
      default:
        return shardsCommon;
    }
  }
  
  /// Retorna o asset de orbe de runa baseado no nível de energia (0.0 a 1.0)
  static String getRuneOrbByLevel(double level) {
    if (level <= 0.0) return runeOrbEmpty;
    if (level < 1.0) return runeOrbHalf;
    return runeOrbFull;
  }
  
  /// Retorna o asset de cristal rúnico baseado no tamanho
  static String getRuneCrystalBySize(String size) {
    switch (size.toLowerCase()) {
      case 'small':
      case 'pequeno':
        return runeCrystalSmall;
      case 'medium':
      case 'médio':
      case 'medio':
        return runeCrystalMedium;
      case 'large':
      case 'grande':
        return runeCrystalLarge;
      default:
        return runeCrystalMedium;
    }
  }
}
