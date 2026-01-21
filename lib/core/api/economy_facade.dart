import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client_provider.dart';
import 'api_errors.dart';

/// Facade para todas as operações de escrita na economia do jogo.
/// Centraliza chamadas RPC e tratamento de erros.
class EconomyFacade {
  static final EconomyFacade instance = EconomyFacade._internal();
  EconomyFacade._internal();

  SupabaseClient get _client => SupabaseClientProvider.client;

  /// Abre um baú do usuário.
  /// Retorna o ID do ledger gerado.
  Future<String> openChest(String userChestId) async {
    return _callRpc('open_chest', {'user_chest_id': userChestId});
  }

  /// Compra um item da loja.
  /// Retorna o ID do ledger gerado.
  Future<String> purchaseShopItem(String shopItemId) async {
    return _callRpc('purchase_shop_item', {'shop_item_id': shopItemId});
  }

  /// Melhora uma carta.
  /// Retorna true se sucesso.
  Future<bool> upgradeCard(String cardId) async {
    final result = await _callRpc('upgrade_card', {'card_id': cardId});
    return result == true;
  }

  /// Desbloqueia uma carta se tiver partes suficientes.
  /// Retorna true se desbloqueou.
  Future<bool> unlockCardIfReady(String cardId) async {
    final result = await _callRpc('unlock_card_if_ready', {'card_id': cardId});
    return result == true;
  }

  /// Aplica partes de carta (ex: drop de partida).
  /// Retorna o ID do ledger.
  Future<String> applyCardParts(String cardId, int amount, String sourceId) async {
    return _callRpc('apply_card_parts', {
      'p_card_id': cardId,
      'p_parts_delta': amount,
      'p_source_id': sourceId,
    });
  }

  /// Método genérico para chamar RPCs com tratamento de erro padronizado.
  Future<T> _callRpc<T>(String functionName, Map<String, dynamic> params) async {
    try {
      debugPrint('🌐 EconomyFacade: Calling $functionName with $params');
      final response = await _client.rpc(functionName, params: params);
      return response as T;
    } on PostgrestException catch (e) {
      debugPrint('❌ EconomyFacade Error ($functionName): ${e.message}');
      throw ServerException(e.message, code: e.code, originalError: e);
    } catch (e) {
      debugPrint('❌ EconomyFacade Unexpected Error ($functionName): $e');
      throw ApiException('Erro inesperado ao processar transação.', originalError: e);
    }
  }
}
