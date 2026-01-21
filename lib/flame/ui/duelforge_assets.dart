import 'package:flame/game.dart';

class DuelForgeAssets {
  // Caminhos base
  static const String _basePath = 'ui/cards/';

  // Frames e Overlays
  static const String cardFrameBase = '${_basePath}card_frame_base.png';
  static const String rarityCommonOverlay = '${_basePath}rarity_common_overlay.png';
  static const String rarityRareOverlay = '${_basePath}rarity_rare_overlay.png';
  static const String rarityEpicOverlay = '${_basePath}rarity_epic_overlay.png';
  static const String rarityLegendaryOverlay = '${_basePath}rarity_legendary_overlay.png';

  // UI Elements
  static const String cardNamePlate = '${_basePath}card_name_plate.png';
  static const String cardLevelBadge = '${_basePath}card_level_badge.png';
  static const String cardFragmentPlate = '${_basePath}card_fragment_plate.png';
  static const String iconUpgradeReady = '${_basePath}icon_upgrade_ready.png';
  static const String cardSilhouetteLocked = '${_basePath}card_silhouette_locked.png';

  /// Carrega todos os assets necessários para as cartas de uma só vez.
  static Future<void> carregarAssetsCartas(FlameGame game) async {
    await game.images.loadAll([
      cardFrameBase,
      rarityCommonOverlay,
      rarityRareOverlay,
      rarityEpicOverlay,
      rarityLegendaryOverlay,
      cardNamePlate,
      cardLevelBadge,
      cardFragmentPlate,
      iconUpgradeReady,
      cardSilhouetteLocked,
    ]);
  }

  /// Retorna o path do overlay baseado na raridade (string em minúsculo).
  static String getRarityOverlay(String raridade) {
    switch (raridade.toLowerCase()) {
      case 'rare':
      case 'raro':
        return rarityRareOverlay;
      case 'epic':
      case 'epico':
      case 'épico':
        return rarityEpicOverlay;
      case 'legendary':
      case 'lendario':
      case 'lendário':
        return rarityLegendaryOverlay;
      case 'common':
      case 'comum':
      default:
        return rarityCommonOverlay;
    }
  }
}
