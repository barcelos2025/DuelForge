import 'dart:async';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SyncOperation {
  final String id;
  final String type;
  final Map<String, dynamic> payload;
  final int timestamp;

  SyncOperation({
    required this.id,
    required this.type,
    required this.payload,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'payload': payload,
    'timestamp': timestamp,
  };

  factory SyncOperation.fromJson(Map<String, dynamic> json) => SyncOperation(
    id: json['id'],
    type: json['type'],
    payload: Map<String, dynamic>.from(json['payload']),
    timestamp: json['timestamp'],
  );
}

class SyncService {
  static const String _boxName = 'sync_queue';
  late Box _box;
  bool _isProcessing = false;
  Timer? _retryTimer;

  // Singleton
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    _processQueue(); // Tenta processar ao iniciar
    
    // Tenta processar periodicamente (a cada 5 minutos) para garantir sincronia
    _retryTimer = Timer.periodic(const Duration(minutes: 5), (_) => _processQueue());
  }

  /// Adiciona uma operação à fila e tenta processar imediatamente.
  Future<void> enqueue(String type, Map<String, dynamic> payload) async {
    final op = SyncOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // ID simples
      type: type,
      payload: payload,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    await _box.add(jsonEncode(op.toJson()));
    print('📥 Operação enfileirada: $type');
    
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isProcessing || _box.isEmpty) return;
    
    // Verifica conexão básica (se Supabase não estiver inicializado ou sem sessão, aborta)
    if (Supabase.instance.client.auth.currentSession == null) return;

    _isProcessing = true;

    try {
      // Processa item por item (FIFO)
      // Hive não garante ordem perfeita se deletarmos do meio, mas aqui pegamos o índice 0 sempre.
      while (_box.isNotEmpty) {
        final item = _box.getAt(0);
        final op = SyncOperation.fromJson(jsonDecode(item));

        print('🔄 Processando sincronização: ${op.type}...');

        bool success = await _executeOperation(op);

        if (success) {
          await _box.deleteAt(0); // Remove da fila se sucesso
          print('✅ Sincronizado: ${op.type}');
        } else {
          // Se falhou, para o processamento e tenta depois (mantém ordem)
          print('⚠️ Falha na sincronização. Tentando novamente mais tarde.');
          break;
        }
      }
    } catch (e) {
      print('❌ Erro fatal no processamento da fila: $e');
    } finally {
      _isProcessing = false;
    }
  }

  Future<bool> _executeOperation(SyncOperation op) async {
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) return false;

      switch (op.type) {
        case 'upsert_deck':
          await _syncUpsertDeck(client, user.id, op.payload);
          return true;
          
        case 'delete_deck':
          await _syncDeleteDeck(client, user.id, op.payload);
          return true;
          
        case 'update_profile':
          await _syncUpdateProfile(client, user.id, op.payload);
          return true;

        case 'upsert_user_card':
          await _syncUpsertUserCard(client, user.id, op.payload);
          return true;
          
        default:
          print('Tipo de operação desconhecido: ${op.type}');
          return true; // Remove da fila para não travar
      }
    } catch (e) {
      print('Erro ao executar ${op.type}: $e');
      return false; // Mantém na fila
    }
  }

  // --- Implementações Específicas ---

  Future<void> _syncUpdateProfile(SupabaseClient client, String userId, Map<String, dynamic> data) async {
    final updateData = {
      'coins': data['coins'],
      'rubies': data['rubies'],
      'runes': data['runes'],
      'trophies': data['trophies'],
      'xp': data['xp'],
      'level': data['level'],
      'current_arena_id': data['current_arena_id'],
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (data.containsKey('avatar_id')) {
      updateData['avatar_id'] = data['avatar_id'];
    }

    await client.from('players').update(updateData).eq('id', userId);
  }

  Future<void> _syncUpsertUserCard(SupabaseClient client, String userId, Map<String, dynamic> data) async {
    await client.from('user_cards').upsert({
      'user_id': userId,
      'card_id': data['card_id'],
      'level': data['level'],
      'cards_count': data['cards_count'] ?? 0, // Se tiver sistema de contagem
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id, card_id');
  }

  Future<void> _syncUpsertDeck(SupabaseClient client, String userId, Map<String, dynamic> data) async {
    // 1. Upsert Deck Metadata
    final deckResponse = await client
        .from('decks')
        .upsert({
          'user_id': userId,
          'name': data['name'],
          'is_active': data['is_active'],
        }, onConflict: 'user_id, name')
        .select()
        .single();
    
    final deckId = deckResponse['id'];

    // 2. Sync Cards
    await client.from('deck_cards').delete().eq('deck_id', deckId);

    final List<String> cardIds = List<String>.from(data['card_ids']);
    if (cardIds.isNotEmpty) {
      final cardsData = cardIds.asMap().entries.map((entry) {
        return {
          'deck_id': deckId,
          'card_id': entry.value,
          'position': entry.key,
        };
      }).toList();

      await client.from('deck_cards').insert(cardsData);
    }
  }

  Future<void> _syncDeleteDeck(SupabaseClient client, String userId, Map<String, dynamic> data) async {
    await client
        .from('decks')
        .delete()
        .match({'user_id': userId, 'name': data['name']});
  }
}
