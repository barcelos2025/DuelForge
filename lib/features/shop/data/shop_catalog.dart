import 'shop_models.dart';

class ShopCatalog {
  // --- Pacotes de Rubis (Hard Currency) ---
  static const List<ShopItem> gemPacks = [
    ShopItem(
      id: 'rubies_pouch',
      name: 'Algibeira de Rubis',
      description: '80 Rubis',
      type: ItemType.currency,
      cost: 5, // R$ 4,90 (Simulado em centavos ou valor base)
      costType: CurrencyType.realMoney,
      quantity: 80,
      assetPath: 'assets/ui/icons/rubies_small.png',
    ),
    ShopItem(
      id: 'rubies_bucket',
      name: 'Balde de Rubis',
      description: '500 Rubis',
      type: ItemType.currency,
      cost: 28, // R$ 27,90
      costType: CurrencyType.realMoney,
      quantity: 500,
      assetPath: 'assets/ui/icons/rubies_medium.png',
    ),
    ShopItem(
      id: 'rubies_wagon',
      name: 'Vagão de Rubis',
      description: '1200 Rubis',
      type: ItemType.currency,
      cost: 55, // R$ 54,90
      costType: CurrencyType.realMoney,
      quantity: 1200,
      assetPath: 'assets/ui/icons/rubies_large.png',
    ),
  ];

  // --- Pacotes de Ouro (Soft Currency) ---
  static const List<ShopItem> goldPacks = [
    ShopItem(
      id: 'gold_pouch',
      name: 'Bolsa de Ouro',
      description: '1000 Ouro',
      type: ItemType.currency,
      cost: 60,
      costType: CurrencyType.rubies,
      quantity: 1000,
      assetPath: 'assets/ui/icons/gold_small.png',
    ),
    ShopItem(
      id: 'gold_bucket',
      name: 'Balde de Ouro',
      description: '10.000 Ouro',
      type: ItemType.currency,
      cost: 500,
      costType: CurrencyType.rubies,
      quantity: 10000,
      assetPath: 'assets/ui/icons/gold_medium.png',
    ),
  ];

  // --- Baús (Gacha Ético) ---
  static const Map<String, ChestDefinition> chests = {
    'wooden': ChestDefinition(
      id: 'wooden',
      name: 'Baú de Madeira',
      unlockTimeSeconds: 3 * 60 * 60, // 3 horas
      minGold: 100,
      maxGold: 200,
      totalCards: 10,
      probabilities: {Rarity.common: 0.9, Rarity.rare: 0.1, Rarity.epic: 0.0, Rarity.legendary: 0.0},
    ),
    'silver': ChestDefinition(
      id: 'silver',
      name: 'Baú de Prata',
      unlockTimeSeconds: 8 * 60 * 60, // 8 horas
      minGold: 300,
      maxGold: 500,
      totalCards: 30,
      probabilities: {Rarity.common: 0.8, Rarity.rare: 0.18, Rarity.epic: 0.02, Rarity.legendary: 0.0},
    ),
    'magical': ChestDefinition(
      id: 'magical',
      name: 'Baú Mágico',
      unlockTimeSeconds: 12 * 60 * 60, // 12 horas
      minGold: 1000,
      maxGold: 1500,
      totalCards: 80,
      probabilities: {Rarity.common: 0.6, Rarity.rare: 0.3, Rarity.epic: 0.09, Rarity.legendary: 0.01},
    ),
  };
}
