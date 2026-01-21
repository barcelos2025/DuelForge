import 'package:flutter/foundation.dart';
import '../../profile/services/profile_service.dart';
import '../domain/shop_models.dart';
import '../data/shop_catalog.dart';

class EconomyService extends ChangeNotifier {
  final ProfileService _profileService;

  EconomyService(this._profileService);

  // --- Transações ---

  /// Compra um item usando moeda do jogo (Ouro ou Rubis).
  Future<bool> purchaseItem(ShopItem item) async {
    if (item.costType == CurrencyType.realMoney) {
      // Integração com In-App Purchase (Google Play / App Store)
      // Aqui simularíamos a chamada à API de pagamentos
      debugPrint('💰 Iniciando fluxo de pagamento real para: ${item.name}');
      await Future.delayed(const Duration(seconds: 2)); // Simula delay
      // Sucesso simulado
      _deliverItem(item);
      return true;
    }

    // Verificação de Saldo
    if (item.costType == CurrencyType.gold) {
      if (_profileService.profile.coins < item.cost) return false;
      _profileService.addCoins(-item.cost);
    } else if (item.costType == CurrencyType.rubies) {
      if (_profileService.profile.rubies < item.cost) return false;
      _profileService.profile.rubies -= item.cost;
      await _profileService.save(); // Salva alteração de rubis
    }

    _deliverItem(item);
    return true;
  }

  void _deliverItem(ShopItem item) {
    debugPrint('📦 Entregando item: ${item.name}');
    
    switch (item.type) {
      case ItemType.currency:
        if (item.id.contains('gold')) {
          _profileService.addCoins(item.quantity ?? 0);
        } else if (item.id.contains('rubies')) {
          _profileService.profile.rubies += (item.quantity ?? 0);
          _profileService.save();
        }
        break;
      case ItemType.card:
        if (item.relatedCardId != null) {
          // Adiciona cartas à coleção (Lógica de conversão em fragmentos se já tiver)
          // ProfileService precisaria de um método `addCardFragments`
          // _profileService.addCardFragments(item.relatedCardId!, item.quantity ?? 1);
          debugPrint('   -> ${item.quantity}x ${item.relatedCardId}');
        }
        break;
      case ItemType.cosmetic:
        // Adiciona flag de cosmético desbloqueado
        break;
      default:
        break;
    }
    
    // Sincronizar com Supabase (Backend)
    // SyncService().enqueue('transaction', {'item_id': item.id, ...});
  }

  // --- Loja Diária (Daily Deals) ---
  
  List<ShopItem> _dailyDeals = [];
  DateTime? _lastDailyRefresh;

  List<ShopItem> get dailyDeals {
    final now = DateTime.now();
    // Refresh a cada 24h (Simulado: se mudou o dia)
    if (_lastDailyRefresh == null || _lastDailyRefresh!.day != now.day) {
      _refreshDailyDeals();
    }
    return _dailyDeals;
  }

  void _refreshDailyDeals() {
    _dailyDeals = [
      // Exemplo: 3 cartas aleatórias por Ouro
      ShopItem(
        id: 'daily_card_1',
        name: 'Arqueira Fiorde',
        description: '10x Cartas',
        type: ItemType.card,
        cost: 100,
        costType: CurrencyType.gold,
        quantity: 10,
        relatedCardId: 'arqueira_fiorde',
        assetPath: 'assets/cards/arqueira_fiorde.png',
      ),
      ShopItem(
        id: 'daily_card_2',
        name: 'Martelo Trovão',
        description: '5x Cartas Raras',
        type: ItemType.card,
        cost: 250,
        costType: CurrencyType.gold,
        quantity: 5,
        relatedCardId: 'martelo_trovao',
        assetPath: 'assets/cards/martelo_trovao.png',
      ),
      // 1 Item Grátis (Retenção)
      ShopItem(
        id: 'daily_free',
        name: 'Presente Diário',
        description: '50 Ouro',
        type: ItemType.currency,
        cost: 0,
        costType: CurrencyType.gold,
        quantity: 50,
        assetPath: 'assets/ui/icons/gold_small.png',
      ),
    ];
    _lastDailyRefresh = DateTime.now();
    notifyListeners();
  }
}
