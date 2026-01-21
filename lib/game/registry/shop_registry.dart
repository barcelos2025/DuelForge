import 'package:flutter/foundation.dart';
import '../../core/content/content_sdk.dart';
import '../../core/content/content_models.dart';
import 'registry_bus.dart';

class ShopRegistry {
  static final ShopRegistry instance = ShopRegistry._internal();
  ShopRegistry._internal();

  ShopDef? _config;

  void init() {
    _refresh();
    ContentSDK.instance.currentVersionNotifier.addListener(_refresh);
  }

  void _refresh() {
    _config = ContentSDK.instance.getContent('shop', ShopDef.fromJson);
    
    if (_config != null) {
      debugPrint('🛒 ShopRegistry: Configuração de loja carregada (Slots: ${_config!.slots}).');
      RegistryBus.instance.notify('shop');
    }
  }

  ShopDef get config {
    // Fallback seguro se não houver config carregada
    return _config ?? ShopDef(refreshHour: 0, slots: 6);
  }
}
