import 'dart:async';

/// Barramento de eventos para notificar atualizações nos Registries.
/// Permite que a UI reaja a mudanças de conteúdo (Hot Reload).
class RegistryBus {
  static final RegistryBus instance = RegistryBus._internal();
  RegistryBus._internal();

  final _controller = StreamController<String>.broadcast();

  /// Stream de notificações. O evento é o nome do registry atualizado (ex: 'cards', 'shop').
  Stream<String> get onRegistryUpdated => _controller.stream;

  void notify(String registryName) {
    _controller.add(registryName);
  }

  void dispose() {
    _controller.close();
  }
}
