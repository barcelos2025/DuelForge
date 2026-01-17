import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../battle/data/card_catalog.dart';

class CardProgressionService {
  static final CardProgressionService _instance = CardProgressionService._internal();
  factory CardProgressionService() => _instance;
  CardProgressionService._internal();

  SharedPreferences? _prefs;

  // In-memory cache
  Map<String, int> _levels = {};
  Map<String, int> _shards = {};
  int _coins = 1000; // Starting coins

  bool get isInitialized => _prefs != null;

  Future<void> init() async {
    if (_prefs != null) return;
    _prefs = await SharedPreferences.getInstance();
    _loadData();
  }

  void _loadData() {
    _coins = _prefs?.getInt('player_coins') ?? 1000;
    
    // Load levels and shards
    // Keys: 'level_cardId', 'shards_cardId'
    for (var card in cardCatalog) {
      _levels[card.cardId] = _prefs?.getInt('level_${card.cardId}') ?? 1;
      _shards[card.cardId] = _prefs?.getInt('shards_${card.cardId}') ?? 0;
    }
  }

  int getCoins() => _coins;
  
  int getLevel(String cardId) => _levels[cardId] ?? 1;
  int getShards(String cardId) => _shards[cardId] ?? 0;

  // Progression Logic
  int getMaxLevel(CardRarity rarity) {
    switch (rarity) {
      case CardRarity.common: return 10;
      case CardRarity.rare: return 12;
      case CardRarity.epic: return 14;
      case CardRarity.legendary: return 15;
    }
  }

  int getShardsForNextLevel(int currentLevel, CardRarity rarity) {
    // Simple exponential curve
    // 2, 4, 8, 15, 25, 40...
    if (currentLevel >= getMaxLevel(rarity)) return 0;
    
    // Base curve
    if (currentLevel == 1) return 2;
    if (currentLevel == 2) return 4;
    if (currentLevel == 3) return 10;
    if (currentLevel == 4) return 20;
    if (currentLevel == 5) return 50;
    if (currentLevel == 6) return 100;
    if (currentLevel == 7) return 200;
    if (currentLevel == 8) return 400;
    if (currentLevel == 9) return 800;
    if (currentLevel >= 10) return 1000 + (currentLevel - 10) * 500;
    
    return 10; // Fallback
  }

  int getCoinsForNextLevel(int currentLevel) {
    // 50, 120, 250, 500, 900, 1500...
    if (currentLevel == 1) return 50;
    if (currentLevel == 2) return 150;
    if (currentLevel == 3) return 400;
    if (currentLevel == 4) return 1000;
    if (currentLevel == 5) return 2000;
    if (currentLevel == 6) return 4000;
    if (currentLevel == 7) return 8000;
    if (currentLevel >= 8) return 10000 + (currentLevel - 8) * 5000;
    
    return 50;
  }

  bool canEvolve(String cardId) {
    final def = cardCatalog.firstWhere((c) => c.cardId == cardId, orElse: () => cardCatalog.first);
    final level = getLevel(cardId);
    final shards = getShards(cardId);
    
    if (level >= getMaxLevel(def.rarity)) return false;
    
    final costShards = getShardsForNextLevel(level, def.rarity);
    final costCoins = getCoinsForNextLevel(level);
    
    return shards >= costShards && _coins >= costCoins;
  }

  Future<bool> evolve(String cardId) async {
    if (!canEvolve(cardId)) return false;
    
    final def = cardCatalog.firstWhere((c) => c.cardId == cardId);
    final level = getLevel(cardId);
    final costShards = getShardsForNextLevel(level, def.rarity);
    final costCoins = getCoinsForNextLevel(level);
    
    // Deduct
    _coins -= costCoins;
    _shards[cardId] = (_shards[cardId] ?? 0) - costShards;
    _levels[cardId] = (_levels[cardId] ?? 1) + 1;
    
    // Save
    await _prefs?.setInt('player_coins', _coins);
    await _prefs?.setInt('shards_$cardId', _shards[cardId]!);
    await _prefs?.setInt('level_$cardId', _levels[cardId]!);
    
    return true;
  }

  // Debug: Add resources
  Future<void> debugAddResources(int coins, int shards) async {
    _coins += coins;
    await _prefs?.setInt('player_coins', _coins);
    
    for (var key in _shards.keys) {
      _shards[key] = (_shards[key] ?? 0) + shards;
      await _prefs?.setInt('shards_$key', _shards[key]!);
    }
  }
}
