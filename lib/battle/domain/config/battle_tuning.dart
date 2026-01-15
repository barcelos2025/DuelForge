import 'package:flutter/foundation.dart';

class BattleTuning {
  // Global Settings
  static double gameSpeed = 1.0;
  static double globalStatsMultiplier = 1.0;

  // Power (Elixir)
  static double elixirRegenBase = 0.83; // ~1.2s per elixir
  static double elixirRegenOvertime = 1.66; // 2x speed

  // Spawn Delays (seconds)
  static double spawnDelayLight = 0.25; // Cost 1-3
  static double spawnDelayMedium = 0.5; // Cost 4-6
  static double spawnDelayHeavy = 0.8;  // Cost 7+
  
  // Animation Durations
  static double hitFlashDuration = 0.08;
  static double spawnScaleDuration = 0.4;
  
  // Visuals & Debug
  static bool showDamageNumbers = kDebugMode;
  static bool debugShowHitboxes = false;
  static bool debugShowLanes = false;
  
  // Cheats / Debug Logic
  static bool debugInfinitePower = false;
  static bool debugNoCooldown = false;

  static double getSpawnDelay(int cost) {
    if (cost <= 3) return spawnDelayLight;
    if (cost <= 6) return spawnDelayMedium;
    return spawnDelayHeavy;
  }

  static void applyPreset(String presetName) {
    // Reset to defaults first
    _resetDefaults();

    switch (presetName) {
      case 'fastTests':
        gameSpeed = 2.0;
        spawnDelayLight = 0.1;
        spawnDelayMedium = 0.1;
        spawnDelayHeavy = 0.1;
        debugInfinitePower = true;
        break;
      case 'stressTest':
        gameSpeed = 5.0;
        debugInfinitePower = true;
        debugNoCooldown = true;
        showDamageNumbers = false; // Too much clutter
        break;
      case 'balanced':
      default:
        // Already reset
        break;
    }
  }

  static void _resetDefaults() {
    gameSpeed = 1.0;
    globalStatsMultiplier = 1.0;
    elixirRegenBase = 0.83;
    elixirRegenOvertime = 1.66;
    spawnDelayLight = 0.25;
    spawnDelayMedium = 0.5;
    spawnDelayHeavy = 0.8;
    hitFlashDuration = 0.08;
    spawnScaleDuration = 0.4;
    showDamageNumbers = kDebugMode;
    debugShowHitboxes = false;
    debugShowLanes = false;
    debugInfinitePower = false;
    debugNoCooldown = false;
  }
}
