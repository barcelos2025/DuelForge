
enum CurrencyType { gold, rubies, realMoney }
enum ItemType { card, chest, currency, cosmetic, pass }
enum Rarity { common, rare, epic, legendary }

class ShopItem {
  final String id;
  final String name;
  final String description;
  final ItemType type;
  final int cost;
  final CurrencyType costType;
  final String? assetPath;
  final int? quantity; // Para pacotes de moedas ou cartas
  final String? relatedCardId; // Se for venda de carta específica
  final Map<String, double>? dropRates; // Para baús (Compliance)

  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.cost,
    required this.costType,
    this.assetPath,
    this.quantity,
    this.relatedCardId,
    this.dropRates,
  });
}

class ChestDefinition {
  final String id;
  final String name;
  final int unlockTimeSeconds;
  final int minGold;
  final int maxGold;
  final int totalCards;
  final Map<Rarity, double> probabilities; // Ex: {legendary: 0.01}

  const ChestDefinition({
    required this.id,
    required this.name,
    required this.unlockTimeSeconds,
    required this.minGold,
    required this.maxGold,
    required this.totalCards,
    required this.probabilities,
  });
}
