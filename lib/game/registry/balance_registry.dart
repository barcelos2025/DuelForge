import 'package:flutter/foundation.dart';
import '../../core/content/content_sdk.dart';
import '../../core/content/content_models.dart';
import 'registry_bus.dart';

class BalanceRegistry {
  static final BalanceRegistry instance = BalanceRegistry._internal();
  BalanceRegistry._internal();

  BalanceDef? _def;

  void init() {
    _refresh();
    ContentSDK.instance.currentVersionNotifier.addListener(_refresh);
  }

  void _refresh() {
    _def = ContentSDK.instance.getContent('balance', BalanceDef.fromJson);
    
    if (_def != null) {
      debugPrint('⚖️ BalanceRegistry: Regras de balanceamento carregadas.');
      RegistryBus.instance.notify('balance');
    }
  }

  double get globalDamageMult => _def?.damageMult ?? 1.0;
  double get globalHpMult => _def?.hpMult ?? 1.0;
}
