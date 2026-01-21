import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client_provider.dart';
import 'api_errors.dart';

/// API de leitura para dados do jogo (Game Master).
/// Fornece contratos estáveis para o ContentSDK e outras partes do app.
class GameMasterAPI {
  static final GameMasterAPI instance = GameMasterAPI._internal();
  GameMasterAPI._internal();

  SupabaseClient get _client => SupabaseClientProvider.client;

  /// Obtém o manifesto da versão ativa de conteúdo.
  Future<List<dynamic>> getActiveContentManifest() async {
    return _callRpc('get_active_content_manifest', {});
  }

  /// Obtém um blob de conteúdo específico.
  Future<dynamic> getContentBlob(String blobType) async {
    return _callRpc('get_content_blob', {'p_blob_type': blobType});
  }

  /// Obtém o perfil completo do jogador (View).
  Future<Map<String, dynamic>> getPlayerProfile() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw ApiException('Usuário não autenticado');

      final response = await _client
          .from('player_profile_view')
          .select()
          .eq('user_id', userId)
          .single();
      
      return response;
    } catch (e) {
      _handleError(e, 'getPlayerProfile');
      rethrow;
    }
  }

  /// Obtém todas as cartas do usuário (View).
  Future<List<Map<String, dynamic>>> getUserCards() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw ApiException('Usuário não autenticado');

      final response = await _client
          .from('user_cards_view')
          .select()
          .order('rarity', ascending: true) // Ordenação padrão
          .order('name', ascending: true);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _handleError(e, 'getUserCards');
      rethrow;
    }
  }

  /// Obtém os baús do usuário (View).
  Future<List<Map<String, dynamic>>> getUserChests() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw ApiException('Usuário não autenticado');

      final response = await _client
          .from('user_chests_view')
          .select()
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _handleError(e, 'getUserChests');
      rethrow;
    }
  }

  /// Método genérico para RPCs de leitura.
  Future<T> _callRpc<T>(String functionName, Map<String, dynamic> params) async {
    try {
      final response = await _client.rpc(functionName, params: params);
      return response as T;
    } catch (e) {
      _handleError(e, functionName);
      rethrow;
    }
  }

  void _handleError(dynamic e, String context) {
    debugPrint('❌ GameMasterAPI Error ($context): $e');
    if (e is PostgrestException) {
      throw ServerException(e.message, code: e.code, originalError: e);
    }
    throw ApiException('Erro ao carregar dados do jogo.', originalError: e);
  }
}
