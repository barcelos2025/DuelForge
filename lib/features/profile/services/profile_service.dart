import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/player_profile.dart';
import '../models/user_card.dart';
import '../models/player_deck.dart';
import '../../../battle/domain/services/deck_service.dart';
import '../../battle/domain/models/arena_definition.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/sync_service.dart';
import '../../battle/viewmodels/cards_repository.dart';
import '../../rewards/domain/reward_event_bus.dart';
import '../../rewards/domain/reward_models.dart';

class ProfileService extends ChangeNotifier {
  static const String _boxName = 'player_profile';
  late Box<PlayerProfile> _box;
  late PlayerProfile _profile;

  PlayerProfile get profile => _profile;
  
  int get trophies => _profile.trophies;
  String get avatarId => _profile.avatarId;
  ArenaDefinition get currentArena => ArenaCatalog.getArenaForTrophies(trophies);

  void setAvatar(String newAvatarId) {
    _profile.avatarId = newAvatarId;
    save();
    // Sync
    SyncService().enqueue('update_profile', {'avatar_id': newAvatarId});
  }

  double get winRate {
    // TODO: Implementar histórico de partidas. Por enquanto retorna 0.5 (equilibrado)
    return 0.5;
  }

  double get averageCardLevel {
    if (_profile.userCards.isEmpty) return 1.0;
    final total = _profile.userCards.fold(0, (sum, c) => sum + c.level);
    return total / _profile.userCards.length;
  }

  static Future<ProfileService> init() async {
    // Register Adapters
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(PlayerProfileAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(UserCardAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(PlayerDeckAdapter());

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

    // Ensure default data if empty (e.g. first run or migration)
    if (_profile.decks.isEmpty) {
      final defaultDeck = DeckBuilder.buildDefaultDeck();
      _profile.decks.add(PlayerDeck(id: 'default', name: 'Starter Deck', cardIds: defaultDeck, isActive: true));
      await _profile.save();
    } else {
      // Migration: Fix legacy IDs in existing decks
      await _migrateLegacyDeckIds();
      
      // Validate active deck after migration
      await _validateAndFixActiveDeck();
    }
    
    // Attempt to sync with cloud
    sync();
    
    // Listen to Reward Events to update UI in real-time
    RewardEventBus().onRewardReceived.listen(_onRewardReceived);
    
    notifyListeners();
  }

  void _onRewardReceived(RewardBatch batch) {
    bool changed = false;
    for (final item in batch.items) {
      if (item.type == RewardType.currency) {
        if (item.resourceId == 'gold') {
          _profile.coins += item.amount.toInt();
          changed = true;
        } else if (item.resourceId == 'runes') {
          _profile.runes += item.amount.toInt();
          changed = true;
        } else if (item.resourceId == 'trophies') {
          _profile.trophies += item.amount.toInt();
          changed = true;
        }
      } else if (item.type == RewardType.card_fragment || item.type == RewardType.card_part) {
        // Update card collection locally
        try {
          final card = _profile.userCards.firstWhere(
            (c) => c.cardId == item.resourceId,
            orElse: () {
              // New card!
              final newCard = UserCard(
                cardId: item.resourceId,
                level: 1,
                fragments: 0,
                isObtained: true,
              );
              _profile.userCards.add(newCard);
              return newCard;
            },
          );
          
          // Assuming fragments for now. If we distinguish parts vs fragments in UI model, handle here.
          // For now, Profile model just has 'fragments' (which maps to parts/fragments count).
          card.fragments += item.amount.toInt();
          changed = true;
        } catch (e) {
          print('Error updating local card state: $e');
        }
      }
    }

    if (changed) {
      save();
      notifyListeners();
      print('💰 Profile updated from Reward Event: ${batch.items.length} items processed.');
    }
  }

  Future<void> _validateAndFixActiveDeck() async {
    try {
      final activeDeck = _profile.decks.firstWhere((d) => d.isActive);
      
      // Check if deck is empty or incomplete
      if (activeDeck.cardIds.isEmpty || activeDeck.cardIds.length < 8) {
        print('⚠️ Active deck is empty or incomplete (${activeDeck.cardIds.length} cards). Resetting to starter deck.');
        activeDeck.cardIds = DeckBuilder.buildDefaultDeck();
        activeDeck.name = 'Starter Deck';
        await _profile.save();
        return;
      }
      
      // Validate that all cards exist in the repository
      // We need to load CardsRepository first
      final repo = CardsRepository();
      if (!repo.carregado) {
        await repo.carregar();
      }
      
      bool hasInvalidCards = false;
      for (final cardId in activeDeck.cardIds) {
        try {
          repo.porId(cardId);
        } catch (e) {
          print('⚠️ Invalid card ID in deck: $cardId');
          hasInvalidCards = true;
          break;
        }
      }
      
      if (hasInvalidCards) {
        print('⚠️ Deck contains invalid cards. Resetting to starter deck.');
        activeDeck.cardIds = DeckBuilder.buildDefaultDeck();
        activeDeck.name = 'Starter Deck';
        await _profile.save();
      } else {
        print('✅ Active deck validated: ${activeDeck.name} (${activeDeck.cardIds.length} cards)');
      }
      
    } catch (e) {
      print('⚠️ No active deck found. Creating starter deck.');
      final defaultDeck = DeckBuilder.buildDefaultDeck();
      _profile.decks.add(PlayerDeck(id: 'default', name: 'Starter Deck', cardIds: defaultDeck, isActive: true));
      await _profile.save();
    }
  }

  Future<void> _migrateLegacyDeckIds() async {
    bool changed = false;
    
    // 1. Migrate Decks
    for (var deck in _profile.decks) {
      final oldIds = List<String>.from(deck.cardIds);
      final newIds = deck.cardIds.map(_cleanId).toList();
      if (!listEquals(deck.cardIds, newIds)) {
        deck.cardIds = newIds;
        changed = true;
        print('🔄 Migrated deck "${deck.name}":');
        print('   Old IDs: $oldIds');
        print('   New IDs: $newIds');
      }
    }

    // 2. Migrate Collection
    for (var card in _profile.userCards) {
      final oldId = card.cardId;
      final newId = _cleanId(card.cardId);
      if (card.cardId != newId) {
        card.cardId = newId;
        changed = true;
        print('🔄 Migrated card: $oldId -> $newId');
      }
    }

    if (changed) {
      print('🔄 ProfileService: Migrated legacy card IDs to new format.');
      await _profile.save();
    } else {
      print('✅ ProfileService: No migration needed, IDs are clean.');
      // Debug: Show current deck IDs
      try {
        final activeDeck = _profile.decks.firstWhere((d) => d.isActive);
        print('📋 Active deck "${activeDeck.name}" IDs: ${activeDeck.cardIds}');
      } catch (e) {
        print('⚠️ No active deck found');
      }
    }
  }

  String _cleanId(String id) {
    if (id.startsWith('df_card_')) {
      // Remove prefix 'df_card_' and suffix '_v01.jpg' or similar
      // Regex approach or simple string manipulation
      // Format: df_card_NAME_v01.jpg -> NAME
      // Some might be .png
      var clean = id.replaceFirst('df_card_', '');
      // Remove extension
      clean = clean.replaceAll('.jpg', '').replaceAll('.png', '');
      // Remove version suffix if present (e.g. _v01, _v0)
      clean = clean.replaceAll(RegExp(r'_v0\d*'), '');
      return clean;
    }
    return id;
  }

  Future<void> sync() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Call RPC to get full state
      final response = await Supabase.instance.client.rpc('get_full_player_state');
      
      if (response != null) {
        final data = response as Map<String, dynamic>;
        final profileData = data['profile'] as Map<String, dynamic>;
        final collectionData = (data['collection'] as List<dynamic>).cast<Map<String, dynamic>>();
        final decksData = (data['decks'] as List<dynamic>).cast<Map<String, dynamic>>();

        // Update Profile Fields
        _profile.nickname = profileData['nickname'] ?? _profile.nickname;
        _profile.country = profileData['country_iso2'] ?? _profile.country; // Note: schema uses country_iso2
        _profile.trophies = profileData['trophies'] ?? _profile.trophies;
        _profile.coins = profileData['coins'] ?? _profile.coins;
        _profile.rubies = profileData['rubies'] ?? _profile.rubies;
        _profile.runes = profileData['runes'] ?? _profile.runes;
        _profile.level = profileData['level'] ?? _profile.level;
        _profile.currentArenaId = profileData['current_arena_id'] ?? _profile.currentArenaId;
        _profile.currentArenaId = profileData['current_arena_id'] ?? _profile.currentArenaId;
        _profile.xp = profileData['xp'] ?? _profile.xp;
        _profile.isMuted = profileData['is_muted'] ?? _profile.isMuted;
        
        // Tracking for Tilt Assist
        // We might need to store this locally or sync it. For now, local session is fine or simple persistent field.
        // Let's assume it's transient for session or stored in Hive if we add field to model.
        // Since I can't easily change Hive model without generator, I'll keep it in memory for now.


        // Update Collection
        _profile.userCards = collectionData.map((d) => UserCard.fromJson(d)).toList();

        // Update Decks
        _profile.decks = decksData.map((d) => PlayerDeck.fromJson(d)).toList();

        await _profile.save();
        notifyListeners();
        print('Profile synced successfully.');
      }
    } catch (e) {
      print('Profile Sync Error (Offline?): $e');
      // On error, we just keep using cached data
    }
  }

  Future<void> save() async {
    await _profile.save();
    notifyListeners();
  }
  
  Future<void> saveDeck(List<String> deckIds) async {
    PlayerDeck activeDeck;
    try {
      activeDeck = _profile.decks.firstWhere((d) => d.isActive);
      activeDeck.cardIds = deckIds;
    } catch (e) {
      activeDeck = PlayerDeck(id: 'new_deck', name: 'Deck 1', cardIds: deckIds, isActive: true);
      _profile.decks.add(activeDeck);
    }
    await save();
    
    // Sync to cloud via Queue
    SyncService().enqueue('upsert_deck', {
      'name': activeDeck.name,
      'is_active': activeDeck.isActive,
      'card_ids': activeDeck.cardIds,
    });
  }

  Future<void> createDeck(String name) async {
    if (_profile.decks.length >= 5) {
      throw Exception('Limite máximo de 5 decks atingido.');
    }
    
    // Gera ID único local
    final newId = 'deck_${DateTime.now().millisecondsSinceEpoch}';
    
    // Cria novo deck com cartas iniciais para não começar vazio
    final newDeck = PlayerDeck(
      id: newId, 
      name: name, 
      cardIds: DeckBuilder.buildDefaultDeck(), 
      isActive: false // Nasce inativo
    );
    
    _profile.decks.add(newDeck);
    await save();
    
    // Sincroniza criação
    SyncService().enqueue('upsert_deck', {
      'name': newDeck.name,
      'is_active': newDeck.isActive,
      'card_ids': newDeck.cardIds,
    });
  }

  Future<void> setActiveDeck(String deckId) async {
    bool changed = false;
    
    for (var d in _profile.decks) {
      if (d.id == deckId) {
        if (!d.isActive) {
          d.isActive = true;
          changed = true;
          SyncService().enqueue('upsert_deck', {
            'name': d.name,
            'is_active': true,
            'card_ids': d.cardIds,
          });
        }
      } else {
        if (d.isActive) {
          d.isActive = false;
          changed = true;
          SyncService().enqueue('upsert_deck', {
            'name': d.name,
            'is_active': false,
            'card_ids': d.cardIds,
          });
        }
      }
    }
    
    if (changed) {
      await save();
      notifyListeners();
    }
  }

  Future<void> deleteDeck(String deckId) async {
    final deck = _profile.decks.firstWhere((d) => d.id == deckId, orElse: () => throw Exception('Deck não encontrado'));
    
    if (deck.isActive) {
      throw Exception('Não é possível excluir o deck ativo.');
    }
    if (_profile.decks.length <= 1) {
      throw Exception('Você deve ter pelo menos um deck.');
    }

    _profile.decks.removeWhere((d) => d.id == deckId);
    await save();
    
    // Sincroniza exclusão
    SyncService().enqueue('delete_deck', {
      'name': deck.name,
    });
  }

  Future<void> renameDeck(String deckId, String newName) async {
    final deck = _profile.decks.firstWhere((d) => d.id == deckId, orElse: () => throw Exception('Deck não encontrado'));
    deck.name = newName;
    await save();
    
    // Sincroniza renomeação
    SyncService().enqueue('upsert_deck', {
      'name': deck.name,
      'is_active': deck.isActive,
      'card_ids': deck.cardIds,
    });
  }

  void _syncProfile() {
    SyncService().enqueue('update_profile', {
      'coins': _profile.coins,
      'rubies': _profile.rubies,
      'runes': _profile.runes,
      'trophies': _profile.trophies,
      'xp': _profile.xp,
      'level': _profile.level,
      'current_arena_id': _profile.currentArenaId,
    });
  }

  void addCoins(int amount) {
    _profile.coins += amount;
    save();
    _syncProfile();
  }
  
  void addTrophies(int amount) {
    _profile.trophies += amount;
    if (_profile.trophies < 0) _profile.trophies = 0;
    save();
    _syncProfile();
  }

  void addRunes(int amount) {
    _profile.runes += amount;
    save();
    _syncProfile();
  }
  
  void addXp(int amount) {
    _profile.xp += amount;
    // Simple level up logic: level = sqrt(xp/100) or similar, for now just increment
    // Let's keep level manual or simple linear for now
    save();
    _syncProfile();
  }

  bool canUpgrade(String cardId, int cost) {
    return _profile.coins >= cost;
  }

  void upgradeCard(String cardId, int cost) {
    if (!canUpgrade(cardId, cost)) return;

    _profile.coins -= cost;
    
    // Find card in userCards
    try {
      final card = _profile.userCards.firstWhere((c) => c.cardId == cardId);
      card.level++;
      _profile.xp += 10 * card.level;
      
      // Sync specific card update
      SyncService().enqueue('upsert_user_card', {
        'card_id': card.cardId,
        'level': card.level,
        'cards_count': card.fragments,
      });
      
    } catch (e) {
      // Card not found? Should not happen if UI is correct
      print('Error upgrading card: $cardId not found in collection');
    }
    
    save();
    _syncProfile(); // Sync coins and XP
  }
  
  int getCardLevel(String cardId) {
    try {
      return _profile.userCards.firstWhere((c) => c.cardId == cardId).level;
    } catch (e) {
      return 1; // Default level
    }
  }

  // --- Audio Settings ---
  
  bool get isMuted => _profile.isMuted;
  
  void setMuted(bool muted) {
    _profile.isMuted = muted;
    save();
    // Sync to cloud
    SyncService().enqueue('update_profile', {'is_muted': muted});
    notifyListeners();
  }

  // --- Match Tracking ---
  int _consecutiveLosses = 0;
  int get consecutiveLosses => _consecutiveLosses;

  void reportMatchResult(bool victory) {
    if (victory) {
      _consecutiveLosses = 0;
    } else {
      _consecutiveLosses++;
    }
    // notifyListeners(); // Not strictly needed for UI, but good for debug
  }
}
