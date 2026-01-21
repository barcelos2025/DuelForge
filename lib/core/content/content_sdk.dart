import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart'; // Necessário adicionar ao pubspec se não tiver, ou usar hash simples

import 'content_models.dart';
import 'content_defaults.dart';
import 'content_validator.dart';
import 'content_cache.dart';

class ContentSDK {
  static final ContentSDK instance = ContentSDK._internal();
  ContentSDK._internal();

  final ValueNotifier<String?> currentVersionNotifier = ValueNotifier(null);
  
  // Cache em memória para acesso rápido síncrono
  final Map<String, dynamic> _memoryCache = {};

  bool _isInitialized = false;

  /// Inicializa o SDK: carrega cache, verifica update e aplica.
  Future<void> inicializar() async {
    if (_isInitialized) return;

    debugPrint('📦 ContentSDK: Inicializando...');

    // 1. Carregar do Cache Local (rápido)
    await _loadFromCache();

    // 2. Verificar Update no Supabase (async)
    // Não awaitamos aqui para não bloquear o boot se estiver sem internet,
    // mas em um jogo real talvez quiséssemos mostrar "Checking updates..."
    _checkForUpdates().catchError((e) {
      debugPrint('⚠️ ContentSDK: Falha ao verificar updates: $e');
    });

    _isInitialized = true;
  }

  /// Retorna o objeto tipado do cache em memória
  T? getContent<T>(String blobType, T Function(Map<String, dynamic>) factory) {
    final data = _memoryCache[blobType];
    if (data == null) return null;
    
    // Se for lista (ex: card_catalog), o factory deve lidar ou usamos outro método
    if (data is List) {
       // Hack para listas: o factory espera Map, mas aqui é List.
       // O ideal seria ter métodos separados getListContent.
       // Por simplicidade, assumimos que T sabe lidar ou retornamos null.
       return null; 
    }
    return factory(data);
  }

  List<T> getListContent<T>(String blobType, T Function(Map<String, dynamic>) factory) {
    final data = _memoryCache[blobType];
    if (data is! List) return [];
    return data.map((e) => factory(e)).toList();
  }

  Future<void> _loadFromCache() async {
    final versionId = await ContentCache.getVersionId();
    if (versionId != null) {
      debugPrint('📦 ContentSDK: Carregando versão cacheada: $versionId');
      currentVersionNotifier.value = versionId;

      // Carregar blobs conhecidos
      for (var type in ContentDefaults.all.keys) {
        final jsonStr = await ContentCache.getBlob(type);
        if (jsonStr != null && ContentValidator.validate(type, jsonStr)) {
          _memoryCache[type] = jsonDecode(jsonStr);
        } else {
          // Fallback para default se cache corrompido
          debugPrint('⚠️ ContentSDK: Cache corrompido para $type, usando default.');
          _memoryCache[type] = jsonDecode(ContentDefaults.all[type]!);
        }
      }
    } else {
      debugPrint('📦 ContentSDK: Nenhum cache encontrado, usando defaults.');
      _applyDefaults();
    }
  }

  void _applyDefaults() {
    for (var entry in ContentDefaults.all.entries) {
      _memoryCache[entry.key] = jsonDecode(entry.value);
    }
  }

  Future<void> _checkForUpdates() async {
    try {
      // 1. Obter Manifesto Remoto
      final response = await Supabase.instance.client.rpc('get_active_content_manifest');
      final manifest = ContentManifest.fromJson(response as List<dynamic>);

      if (manifest.versionId.isEmpty) {
        debugPrint('⚠️ ContentSDK: Nenhum manifesto ativo encontrado.');
        return;
      }

      final currentVersion = await ContentCache.getVersionId();
      if (manifest.versionId == currentVersion) {
        debugPrint('📦 ContentSDK: Já está na versão mais recente (${manifest.label}).');
        return;
      }

      debugPrint('📦 ContentSDK: Nova versão encontrada: ${manifest.label} (${manifest.versionId})');
      await _downloadAndApplyUpdate(manifest);

    } catch (e) {
      debugPrint('❌ ContentSDK: Erro ao verificar updates: $e');
      rethrow;
    }
  }

  Future<void> _downloadAndApplyUpdate(ContentManifest manifest) async {
    final Map<String, String> newBlobs = {};
    final Map<String, String> newChecksums = {};

    // 1. Baixar Blobs
    for (var entry in manifest.blobs.entries) {
      final type = entry.key;
      final remoteChecksum = entry.value;

      // Otimização: Se checksum local for igual, não baixa
      final localChecksum = await ContentCache.getChecksum(type);
      if (localChecksum == remoteChecksum) {
        final cachedBlob = await ContentCache.getBlob(type);
        if (cachedBlob != null) {
          debugPrint('📦 ContentSDK: Blob $type inalterado, usando cache.');
          newBlobs[type] = cachedBlob;
          newChecksums[type] = remoteChecksum;
          continue;
        }
      }

      debugPrint('⬇️ ContentSDK: Baixando blob $type...');
      final response = await Supabase.instance.client.rpc('get_content_blob', params: {'p_blob_type': type});
      
      // O response vem como Map/List (já decodificado pelo client do Supabase) ou String dependendo da RPC
      // Nossa RPC retorna JSONB, o client dart converte para dynamic.
      // Precisamos converter de volta para String para salvar e validar checksum (se quiséssemos validar hash real)
      final jsonString = jsonEncode(response);

      if (!ContentValidator.validate(type, jsonString)) {
        throw Exception('Validação falhou para o blob $type');
      }

      newBlobs[type] = jsonString;
      newChecksums[type] = remoteChecksum;
    }

    // 2. Salvar Cache (Commit)
    await ContentCache.save(manifest.versionId, newBlobs, newChecksums);

    // 3. Atualizar Memória (Hot Reload)
    for (var entry in newBlobs.entries) {
      _memoryCache[entry.key] = jsonDecode(entry.value);
    }

    currentVersionNotifier.value = manifest.versionId;
    debugPrint('✅ ContentSDK: Atualizado com sucesso para ${manifest.label}!');
  }
}
