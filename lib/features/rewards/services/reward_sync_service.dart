import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/reward_event_bus.dart';
import '../domain/reward_models.dart';

class RewardSyncService {
  final SupabaseClient _supabase;
  Timer? _pollTimer;
  bool _isPolling = false;
  
  // Cache para evitar processar o mesmo ID repetidamente em curto prazo
  final Set<String> _processingIds = {};

  RewardSyncService(this._supabase) {
    _init();
  }

  void _init() {
    // Escuta confirmações de consumo vindas da UI
    RewardEventBus().onRewardConsumed.listen(_markAsConsumed);
    
    // Inicia polling
    startPolling();
  }

  void startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _poll());
    _poll(); // Executa imediatamente
  }

  void stopPolling() {
    _pollTimer?.cancel();
  }

  Future<void> _poll() async {
    if (_isPolling) return;
    _isPolling = true;

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Busca itens não consumidos na outbox
      final response = await _supabase
          .from('reward_outbox')
          .select()
          .eq('user_id', userId)
          .eq('consumed', false)
          .limit(10); // Processa em lotes pequenos

      final List<dynamic> rows = response as List<dynamic>;

      if (rows.isEmpty) return;

      // Agrupa por ledger_id para mostrar recompensas da mesma fonte juntas
      final Map<String, List<dynamic>> byLedger = {};
      
      for (var row in rows) {
        final id = row['id'] as String;
        if (_processingIds.contains(id)) continue;
        
        final ledgerId = row['ledger_id'] as String? ?? 'unknown';
        byLedger.putIfAbsent(ledgerId, () => []).add(row);
        _processingIds.add(id);
      }

      // Emite eventos para cada grupo
      for (var entry in byLedger.entries) {
        final ledgerRows = entry.value;
        final List<String> outboxIds = [];
        final List<RewardItem> allItems = [];

        for (var row in ledgerRows) {
          outboxIds.add(row['id']);
          final jsonRewards = row['rewards_json'] as List<dynamic>;
          for (var r in jsonRewards) {
            allItems.add(RewardItem.fromJson(r, row['id']));
          }
        }

        if (allItems.isNotEmpty) {
          final batch = RewardBatch(
            outboxIds: outboxIds,
            items: allItems,
            sourceId: entry.key,
          );
          
          debugPrint('🎁 RewardSyncService: Emitindo batch ${entry.key} com ${allItems.length} itens.');
          RewardEventBus().emitReward(batch);
        } else {
          // Se não tem itens (estranho), marca como consumido para não travar
          _markAsConsumed(outboxIds);
        }
      }

    } catch (e) {
      debugPrint('❌ Erro no RewardSyncService: $e');
    } finally {
      _isPolling = false;
    }
  }

  Future<void> _markAsConsumed(List<String> outboxIds) async {
    if (outboxIds.isEmpty) return;

    try {
      await _supabase
          .from('reward_outbox')
          .update({'consumed': true})
          .inFilter('id', outboxIds); // Usando inFilter para lista de IDs
      
      // Remove do cache de processamento
      _processingIds.removeAll(outboxIds);
      debugPrint('✅ Recompensas marcadas como consumidas: ${outboxIds.length}');
    } catch (e) {
      debugPrint('❌ Erro ao marcar recompensas como consumidas: $e');
      // Se falhar, remove do cache para tentar novamente no próximo poll
      _processingIds.removeAll(outboxIds);
    }
  }
  Future<void> debugGrantRewards() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('❌ Cannot grant rewards: No user logged in.');
        return;
      }

      debugPrint('🎁 Granting debug rewards...');

      // Grant 500 Gold
      await _supabase.rpc('grant_reward', params: {
        'p_user_id': userId,
        'p_reward_type': 'currency',
        'p_resource_id': 'gold',
        'p_amount': 500,
        'p_source': 'debug_button',
      });
      
      debugPrint('✅ Debug Reward Granted: 500 Gold');
    } catch (e) {
      debugPrint('❌ Error granting debug reward: $e');
    }
  }
}
