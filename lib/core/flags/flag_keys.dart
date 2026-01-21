/// Chaves constantes para Feature Flags.
/// Centraliza os nomes para evitar erros de digitação.
class FlagKeys {
  // Módulos Principais
  static const String shopEnabled = 'shop_enabled';
  static const String eventsEnabled = 'events_enabled';
  static const String telemetryEnabled = 'telemetry_enabled';
  
  // Gameplay
  static const String experimentalVfx = 'experimental_vfx';
  static const String newMatchmaking = 'new_matchmaking_v2';
  
  // Conteúdo Específico
  static const String chestLegendaryEnabled = 'chest_legendary_enabled';
  static const String chestRunicEnabled = 'chest_runic_enabled';
  
  // Kill Switches (Invertidos: true = kill)
  static const String killSwitchAds = 'kill_switch_ads';
}
