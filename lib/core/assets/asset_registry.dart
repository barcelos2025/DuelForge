
import 'package:flame/flame.dart';

class AssetRegistry {
  // Base paths relative to 'assets/' because we will set Flame.images.prefix = 'assets/'
  static const String cardsPath = 'cards/';
  static const String arenasPath = 'arenas/';
  static const String uiPath = 'ui/';

  static Future<void> init() async {
    // Set Flame images prefix to 'assets/' so we can access siblings of 'images/'
    Flame.images.prefix = 'assets/';
  }

  static String getCardAsset(String cardId) {
    // cardId ex: "df_card_thor_v01.jpg"
    return '$cardsPath$cardId';
  }

  static const List<String> _arenaFiles = [
    'df_arena_ragnarok_rift_v01.png',
    'df_arena_niflheim_glacier_v01.png',
    'df_arena_midgard_clearing_v01.png',
    'df_arena_midgard_frontier_v01.png',
    'df_arena_asgard_runic_corridor_v01.png',
    'df_arena_helheim_crypt_v01.png',
  ];

  static String getArenaAsset(int index) {
    // Index 1-based from BattleScreen, adjust to 0-based
    final i = (index - 1).clamp(0, _arenaFiles.length - 1);
    return '$arenasPath${_arenaFiles[i]}';
  }
}
