import 'package:flutter/foundation.dart';
import '../../core/content/content_sdk.dart';
import '../../core/content/content_models.dart';
import 'registry_bus.dart';

class CardRegistry {
  static final CardRegistry instance = CardRegistry._internal();
  CardRegistry._internal();

  final Map<String, CardDef> _cards = {};

  /// Inicializa o registry lendo do SDK e se inscreve para updates.
  void init() {
    _refresh();
    
    // Escuta mudanças de versão no SDK para recarregar
    ContentSDK.instance.currentVersionNotifier.addListener(() {
      _refresh();
    });
  }

  void _refresh() {
    final list = ContentSDK.instance.getListContent('card_catalog', CardDef.fromJson);
    
    _cards.clear();
    for (var def in list) {
      _cards[def.id] = def;
    }

    debugPrint('🃏 CardRegistry: Carregadas ${_cards.length} cartas.');
    RegistryBus.instance.notify('cards');
  }

  /// Retorna a definição de uma carta pelo ID.
  CardDef? getCard(String id) {
    return _cards[id];
  }

  /// Retorna todas as cartas conhecidas.
  List<CardDef> getAllCards() {
    return _cards.values.toList();
  }

  /// Retorna cartas filtradas por raridade.
  List<CardDef> getCardsByRarity(String rarity) {
    return _cards.values.where((c) => c.rarity == rarity).toList();
  }
}
