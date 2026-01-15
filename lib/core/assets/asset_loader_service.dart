
import 'package:flame/flame.dart';
import '../../battle/data/card_catalog.dart';
import 'asset_registry.dart';

class AssetLoaderService {
  static Future<void> preloadAssets(Function(double) onProgress) async {
    final cards = cardCatalog;
    final total = cards.length;
    int loaded = 0;

    for (final card in cards) {
      final path = AssetRegistry.getCardAsset(card.cardId);
      try {
        await Flame.images.load(path);
      } catch (e) {
        print('Failed to load asset: $path');
      }
      loaded++;
      onProgress(loaded / total);
    }
  }
}
