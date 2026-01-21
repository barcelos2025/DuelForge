import 'package:flutter/foundation.dart';
import '../content/content_sdk.dart';
import 'flag_keys.dart';

/// Gerenciador de Feature Flags.
/// Lê configurações do ContentSDK (blob 'feature_flags') e fornece acesso tipado.
class FeatureFlags {
  static final FeatureFlags instance = FeatureFlags._internal();
  FeatureFlags._internal();

  Map<String, dynamic> _flags = {};

  /// Inicializa lendo do SDK e escutando mudanças.
  void init() {
    _refresh();
    ContentSDK.instance.currentVersionNotifier.addListener(_refresh);
  }

  void _refresh() {
    // Tenta carregar o blob 'feature_flags'. Se não existir, usa vazio.
    final data = ContentSDK.instance.getContent('feature_flags', (json) => json);
    if (data != null) {
      _flags = data;
      debugPrint('🚩 FeatureFlags: Atualizadas (${_flags.length} flags).');
    }
  }

  /// Verifica se uma flag está habilitada.
  /// [key]: Chave da flag (use FlagKeys).
  /// [defaultValue]: Valor a retornar se a flag não estiver definida (padrão: false).
  bool isEnabled(String key, {bool defaultValue = false}) {
    final value = _flags[key];
    if (value is bool) return value;
    return defaultValue;
  }

  /// Retorna o valor de uma flag ou o default.
  /// Útil para flags numéricas ou strings (ex: 'max_daily_matches').
  T getValue<T>(String key, T defaultValue) {
    final value = _flags[key];
    if (value is T) return value;
    return defaultValue;
  }

  // --- Helpers de Conveniência ---

  bool get isShopEnabled => isEnabled(FlagKeys.shopEnabled, defaultValue: true);
  bool get isEventsEnabled => isEnabled(FlagKeys.eventsEnabled, defaultValue: true);
  bool get isTelemetryEnabled => isEnabled(FlagKeys.telemetryEnabled, defaultValue: true);
  bool get useExperimentalVfx => isEnabled(FlagKeys.experimentalVfx, defaultValue: false);
  
  bool isChestEnabled(String chestType) {
    // Ex: 'chest_legendary_enabled'
    return isEnabled('chest_${chestType}_enabled', defaultValue: true);
  }
}
