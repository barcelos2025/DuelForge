
import 'dart:collection';
import '../../data/card_catalog.dart';

class DeckService {
  final List<String> _deck = [];
  final List<String> _hand = [];
  final Queue<String> _cycleQueue = Queue<String>();

  DeckService(List<String> startingDeck) {
    if (startingDeck.length != 8) {
      throw Exception("Deck must have exactly 8 cards");
    }
    _deck.addAll(startingDeck);
    _initializeHandAndCycle();
  }

  void _initializeHandAndCycle() {
    _hand.clear();
    _cycleQueue.clear();
    
    // Shuffle deck for initial cycle? 
    // Usually CR has a fixed order or random initial shuffle.
    // Let's assume the input list is the order, or we shuffle it.
    // For determinism, we'll respect the input order for now, 
    // but typically you shuffle the first cycle.
    final shuffled = List<String>.from(_deck)..shuffle();

    // First 4 to hand
    for (int i = 0; i < 4; i++) {
      _hand.add(shuffled[i]);
    }
    
    // Rest to cycle queue
    for (int i = 4; i < 8; i++) {
      _cycleQueue.add(shuffled[i]);
    }
  }

  List<String> getHand() => List.unmodifiable(_hand);
  List<String> get hand => getHand();
  
  String? getNextCardPreview() {
    if (_cycleQueue.isEmpty) return null;
    return _cycleQueue.first;
  }
  String? get nextCard => getNextCardPreview();

  int getCardCost(String cardId) {
    try {
      final def = cardCatalog.firstWhere((c) => c.cardId == cardId);
      return def.cost;
    } catch (e) {
      return 99; // Error cost
    }
  }

  bool canPlay(String cardId, double currentPower) {
    if (!_hand.contains(cardId)) return false;
    final cost = getCardCost(cardId);
    return currentPower >= cost;
  }

  /// Plays the card, updating hand and cycle.
  /// Returns the cardId that was played (confirmation) or null if failed.
  /// Does NOT consume power (PowerService handles that).
  String? play(String cardId) {
    final index = _hand.indexOf(cardId);
    if (index == -1) return null; // Card not in hand

    // 1. Remove from hand
    _hand.removeAt(index);

    // 2. Add played card to end of cycle
    _cycleQueue.addLast(cardId);

    // 3. Move next card from cycle to hand
    if (_cycleQueue.isNotEmpty) {
      final nextCard = _cycleQueue.removeFirst();
      // Insert at the same slot or append? 
      // CR visual: usually fills the empty slot.
      // List.insert allows keeping order, but simple add is easier for logic.
      // Let's insert at the same index to keep hand stable visually if UI maps index.
      _hand.insert(index, nextCard);
    }

    return cardId;
  }
}

class DeckBuilder {
  static List<String> buildDefaultDeck() {
    // Returns a balanced deck from the catalog
    // 1. Tank: Tyr
    // 2. Ranged: Troll Huntress
    // 3. Spell: Thunder Hammer
    // 4. Building: Watchtower
    // 5. Assassin: Bear Berserker
    // 6. Swarm/Cycle: Ice Runner
    // 7. Support: Freyja
    // 8. Air/Special: Odyn Ravens
    
    return [
      'df_card_tyr_v01.jpg',
      'df_card_troll_huntress_v01.jpg',
      'df_card_thunder_hammer_v01.jpg',
      'df_card_watchtower_v01.jpg',
      'df_card_bear_berserker_v01.jpg',
      'df_card_ice_runner_v01.jpg',
      'df_card_freyja_v01.jpg',
      'df_card_odyn_ravens_v01.jpg',
    ];
  }
}
