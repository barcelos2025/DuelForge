
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/player_profile.dart';
import '../../../battle/data/balance_rules.dart';

import '../../../battle/domain/services/deck_service.dart';

class ProfileService extends ChangeNotifier {
  static const String _boxName = 'player_profile';
  late Box<PlayerProfile> _box;
  late PlayerProfile _profile;

  PlayerProfile get profile => _profile;

  static Future<ProfileService> init() async {
    Hive.registerAdapter(PlayerProfileAdapter());
    await Hive.openBox<PlayerProfile>(_boxName);
    
    final service = ProfileService();
    await service._load();
    return service;
  }

  Future<void> _load() async {
    _box = Hive.box<PlayerProfile>(_boxName);
    if (_box.isEmpty) {
      _profile = PlayerProfile();
      await _box.add(_profile);
    } else {
      _profile = _box.getAt(0)!;
    }

    // Ensure deck is initialized
    if (_profile.currentDeck.isEmpty) {
      _profile.currentDeck = DeckBuilder.buildDefaultDeck();
      await _profile.save();
    }

    notifyListeners();
  }

  Future<void> save() async {
    await _profile.save();
    notifyListeners();
  }
  
  Future<void> saveDeck(List<String> deck) async {
    _profile.currentDeck = deck;
    await save();
  }

  void addCoins(int amount) {
    _profile.coins += amount;
    save();
  }

  bool canUpgrade(String cardId, int cost) {
    return _profile.coins >= cost;
  }

  void upgradeCard(String cardId, int cost) {
    if (!canUpgrade(cardId, cost)) return;

    _profile.coins -= cost;
    
    final currentLevel = _profile.cardLevels[cardId] ?? 1;
    _profile.cardLevels[cardId] = currentLevel + 1;
    
    _profile.xp += 10 * currentLevel; // Simple XP formula
    
    save();
  }
  
  int getCardLevel(String cardId) {
    return _profile.cardLevels[cardId] ?? 1;
  }
}
