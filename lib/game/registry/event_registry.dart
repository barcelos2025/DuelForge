import 'package:flutter/foundation.dart';
import '../../core/content/content_sdk.dart';
// import '../../core/content/content_models.dart'; // EventDef ainda não definido no models, usando Map por enquanto
import 'registry_bus.dart';

class EventRegistry {
  static final EventRegistry instance = EventRegistry._internal();
  EventRegistry._internal();

  Map<String, dynamic> _events = {};

  void init() {
    _refresh();
    ContentSDK.instance.currentVersionNotifier.addListener(_refresh);
  }

  void _refresh() {
    // Como EventDef não foi explicitamente solicitado no content_models.dart anterior,
    // vamos assumir que 'events' é um blob que retorna um Map ou List.
    // Usaremos getContent genérico com Map.
    
    final data = ContentSDK.instance.getContent('events', (json) => json);
    
    if (data != null) {
      _events = data;
      debugPrint('🎉 EventRegistry: Eventos carregados.');
      RegistryBus.instance.notify('events');
    }
  }

  Map<String, dynamic> get activeEvents => _events;
}
