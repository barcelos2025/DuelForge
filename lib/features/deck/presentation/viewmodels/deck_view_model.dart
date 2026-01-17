import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../battle/data/card_catalog.dart';
import '../../../profile/services/profile_service.dart';
import '../../domain/deck_types.dart';

class DeckViewModel extends ChangeNotifier {
  final ProfileService profileService;
  
  List<String> currentDeck = [];
  List<CardDefinition> allCards = [];
  
  SelectedCardRef? selected;
  String? errorMessage;

  // Search & Sort State
  String searchQuery = '';
  ReserveSortKey sortKey = ReserveSortKey.type;
  SortOrder sortOrder = SortOrder.asc;
  Timer? _debounceTimer;

  DeckViewModel(this.profileService) {
    _load();
  }

  void _load() {
    currentDeck = List.from(profileService.profile.currentDeck);
    allCards = cardCatalog;
    notifyListeners();
  }

  double get averageCost {
    if (currentDeck.isEmpty) return 0.0;
    final total = currentDeck.fold(0, (sum, id) => sum + _getCost(id));
    return total / currentDeck.length;
  }

  int _getCost(String id) {
    try {
      return allCards.firstWhere((c) => c.cardId == id).cost;
    } catch (_) {
      return 0;
    }
  }

  bool isInDeck(String cardId) {
    return currentDeck.contains(cardId);
  }

  void selectCard(String cardId, DeckSide side, int index) {
    if (selected == null) {
      selected = SelectedCardRef(cardId: cardId, side: side, index: index);
      notifyListeners();
      return;
    }

    if (selected!.side == side) {
      if (selected!.index == index && selected!.cardId == cardId) {
        // Same card tapped again -> Deselect (Toggle)
        clearSelection();
      } else {
        // Same side, different card -> Change selection
        selected = SelectedCardRef(cardId: cardId, side: side, index: index);
        notifyListeners();
      }
    } else {
      // Different side, trigger swap request (handled by UI)
      // We don't do anything here, UI calls swapCards after confirmation
    }
  }

  void clearSelection() {
    selected = null;
    notifyListeners();
  }

  bool canSwap(String targetCardId, DeckSide targetSide, int targetIndex) {
    if (selected == null) return false;

    final sourceId = selected!.cardId;
    final sourceSide = selected!.side;
    
    // Check for duplicates
    if (sourceSide == DeckSide.game && targetSide == DeckSide.reserve) {
      if (currentDeck.contains(targetCardId)) {
        errorMessage = "Carta já está no deck!";
        notifyListeners();
        return false;
      }
    } else if (sourceSide == DeckSide.reserve && targetSide == DeckSide.game) {
      if (currentDeck.contains(sourceId)) {
        errorMessage = "Carta já está no deck!";
        notifyListeners();
        return false;
      }
    }
    
    errorMessage = null;
    return true;
  }

  Future<bool> swapCards(String targetCardId, DeckSide targetSide, int targetIndex) async {
    if (selected == null) return false;
    
    if (!canSwap(targetCardId, targetSide, targetIndex)) {
      return false;
    }

    final sourceId = selected!.cardId;
    final sourceSide = selected!.side;
    final sourceIndex = selected!.index;
    
    if (sourceSide == DeckSide.game && targetSide == DeckSide.reserve) {
      currentDeck[sourceIndex] = targetCardId;
      selected = null;
    } else if (sourceSide == DeckSide.reserve && targetSide == DeckSide.game) {
      currentDeck[targetIndex] = sourceId;
      selected = null;
    }

    await saveDeck();
    notifyListeners();
    return true;
  }

  Future<void> saveDeck() async {
    await profileService.saveDeck(currentDeck);
  }
  
  // Legacy toggle for compatibility if needed, but we are moving to swap logic
  void toggleCard(String cardId) {
    // ... logic if needed
  }

  // ===========================================================================
  // Search & Sort Logic
  // ===========================================================================

  void setSearchQuery(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      searchQuery = query;
      notifyListeners();
    });
  }

  void toggleSortKey() {
    // Order: Type -> Rarity -> Power -> Level -> Type
    switch (sortKey) {
      case ReserveSortKey.type:
        sortKey = ReserveSortKey.rarity;
        break;
      case ReserveSortKey.rarity:
        sortKey = ReserveSortKey.power;
        break;
      case ReserveSortKey.power:
        sortKey = ReserveSortKey.level;
        break;
      case ReserveSortKey.level:
        sortKey = ReserveSortKey.type;
        break;
    }
    notifyListeners();
  }

  void toggleSortOrder() {
    sortOrder = sortOrder == SortOrder.asc ? SortOrder.desc : SortOrder.asc;
    notifyListeners();
  }

  List<CardDefinition> get filteredSortedReserveCards {
    // 1. Filter
    var list = allCards.where((card) {
      // Exclude cards currently in the deck
      if (currentDeck.contains(card.cardId)) return false;

      if (searchQuery.isEmpty) return true;
      final name = card.displayName.toLowerCase();
      final query = searchQuery.toLowerCase();
      return name.contains(query);
    }).toList();

    // 2. Sort
    list.sort((a, b) {
      int result = 0;
      switch (sortKey) {
        case ReserveSortKey.type:
          // User wants: unit < spell < building
          // CardType: tropa, construcao, feitico
          int typeScore(CardType t) {
            if (t == CardType.tropa) return 0;
            if (t == CardType.feitico) return 1;
            return 2; // construcao
          }
          result = typeScore(a.type).compareTo(typeScore(b.type));
          break;
        case ReserveSortKey.rarity:
          // common < rare < epic < legendary
          result = a.rarity.index.compareTo(b.rarity.index);
          break;
        case ReserveSortKey.power:
          result = a.cost.compareTo(b.cost);
          break;
        case ReserveSortKey.level:
          final levelA = profileService.getCardLevel(a.cardId);
          final levelB = profileService.getCardLevel(b.cardId);
          result = levelA.compareTo(levelB);
          break;
      }

      // Apply Order
      if (sortOrder == SortOrder.desc) {
        result = -result;
      }

      // Stable sort (tie-breaker by name)
      if (result == 0) {
        result = a.displayName.compareTo(b.displayName);
      }
      return result;
    });

    return list;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
