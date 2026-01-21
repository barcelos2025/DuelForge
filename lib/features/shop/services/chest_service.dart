import 'dart:math';
import '../domain/shop_models.dart';
import '../data/shop_catalog.dart';

class ChestService {
  final Random _rng = Random();

  /// Simula a abertura de um baú e retorna o conteúdo.
  /// Em produção, isso deve ser validado no servidor para evitar cheats.
  Map<String, dynamic> openChest(String chestId) {
    final def = ShopCatalog.chests[chestId];
    if (def == null) throw Exception('Baú não encontrado');

    // 1. Ouro
    final gold = def.minGold + _rng.nextInt(def.maxGold - def.minGold + 1);

    // 2. Cartas
    final cards = <String, int>{}; // CardId -> Quantity
    
    // Distribuição de raridade
    // Ex: 30 cartas. 
    // Garantir pelo menos 1 rara se probabilidade > 0?
    // Lógica simplificada: rolar para cada carta.
    
    int remainingCards = def.totalCards;
    
    // Garantias (Pity System simplificado)
    // Se for baú mágico, garante X épicas
    if (chestId == 'magical') {
      _addCards(cards, 'martelo_trovao', 2); // Exemplo: 2 Épicas garantidas
      remainingCards -= 2;
    }

    for (int i = 0; i < remainingCards; i++) {
      final roll = _rng.nextDouble();
      Rarity rarity = Rarity.common;
      
      double cumulative = 0.0;
      for (final entry in def.probabilities.entries) {
        cumulative += entry.value;
        if (roll < cumulative) {
          rarity = entry.key;
          break;
        }
      }
      
      // Selecionar carta aleatória da raridade (Mock)
      final cardId = _getRandomCardIdForRarity(rarity);
      cards.update(cardId, (val) => val + 1, ifAbsent: () => 1);
    }

    return {
      'gold': gold,
      'cards': cards,
    };
  }

  String _getRandomCardIdForRarity(Rarity rarity) {
    // Em um sistema real, consultaria o CardCatalog filtrado por raridade e Arena
    switch (rarity) {
      case Rarity.legendary: return 'thor';
      case Rarity.epic: return 'martelo_trovao';
      case Rarity.rare: return 'arqueira_fiorde';
      default: return 'berserker_tundra';
    }
  }
}
