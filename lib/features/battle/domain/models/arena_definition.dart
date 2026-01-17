
import 'package:flutter/foundation.dart';

class ArenaDefinition {
  final String id;
  final String name;
  final int minTrophies;
  final int maxTrophies; // Use -1 for infinite
  final String assetPath;
  final double rewardsMultiplier;

  const ArenaDefinition({
    required this.id,
    required this.name,
    required this.minTrophies,
    required this.maxTrophies,
    required this.assetPath,
    this.rewardsMultiplier = 1.0,
  });

  bool contains(int trophies) {
    if (maxTrophies == -1) {
      return trophies >= minTrophies;
    }
    return trophies >= minTrophies && trophies <= maxTrophies;
  }
}

class ArenaCatalog {
  static const List<ArenaDefinition> arenas = [
    ArenaDefinition(
      id: 'ragnarok_rift',
      name: 'Fenda do Ragnarok',
      minTrophies: 0,
      maxTrophies: 399,
      assetPath: 'assets/arenas/df_arena_ragnarok_rift_v01.png',
    ),
    ArenaDefinition(
      id: 'niflheim_glacier',
      name: 'Lago Glacial de Niflheim',
      minTrophies: 400,
      maxTrophies: 799,
      assetPath: 'assets/arenas/df_arena_niflheim_glacier_v01.png',
    ),
    ArenaDefinition(
      id: 'midgard_clearing',
      name: 'Clareira de Midgard',
      minTrophies: 800,
      maxTrophies: 1199,
      assetPath: 'assets/arenas/df_arena_midgard_clearing_v01.png',
    ),
    ArenaDefinition(
      id: 'midgard_frontier',
      name: 'Fronteira de Midgard',
      minTrophies: 1200,
      maxTrophies: 1599,
      assetPath: 'assets/arenas/df_arena_midgard_frontier_v01.png',
    ),
    ArenaDefinition(
      id: 'asgard_runic_corridor',
      name: 'Corredor Rúnico de Asgard',
      minTrophies: 1600,
      maxTrophies: 1999,
      assetPath: 'assets/arenas/df_arena_asgard_runic_corridor_v01.png',
    ),
    ArenaDefinition(
      id: 'helheim_crypt',
      name: 'Cripta de Helheim',
      minTrophies: 2000,
      maxTrophies: -1, // Infinite
      assetPath: 'assets/arenas/df_arena_helheim_crypt_v01.png',
    ),
  ];

  static ArenaDefinition getArenaForTrophies(int trophies) {
    // If trophies >= 2000, it will match helheim_crypt because maxTrophies is -1
    // We iterate to find the first match.
    try {
      return arenas.firstWhere((arena) => arena.contains(trophies));
    } catch (e) {
      // Fallback if something goes wrong (e.g. negative trophies logic error)
      return arenas.first;
    }
  }

  static ArenaDefinition getNextArena(int trophies) {
    final current = getArenaForTrophies(trophies);
    final index = arenas.indexOf(current);
    if (index < arenas.length - 1) {
      return arenas[index + 1];
    }
    return current; // Max level reached
  }
}
