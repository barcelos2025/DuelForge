import 'package:flutter/foundation.dart';
import '../../core/content/content_sdk.dart';
import '../../core/content/content_models.dart';
import 'registry_bus.dart';

class DropRegistry {
  static final DropRegistry instance = DropRegistry._internal();
  DropRegistry._internal();

  DropTableDef? _def;

  void init() {
    _refresh();
    ContentSDK.instance.currentVersionNotifier.addListener(_refresh);
  }

  void _refresh() {
    _def = ContentSDK.instance.getContent('drop_tables', DropTableDef.fromJson);
    
    if (_def != null) {
      debugPrint('📦 DropRegistry: Tabelas de drop carregadas.');
      RegistryBus.instance.notify('drops');
    }
  }

  List<String> get availableChests {
    return _def?.chests ?? ['wooden']; // Fallback mínimo
  }

  /// Retorna a configuração de uma tabela de drop específica (se houver detalhe no JSON)
  Map<String, dynamic>? getTableConfig(String tableId) {
    return _def?.tables[tableId];
  }
}
