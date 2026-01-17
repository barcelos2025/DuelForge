
import 'arena_definition.dart';

class ArenaProgressionService {
  // Pure function to get arena from trophies
  ArenaDefinition getArena(int trophies) {
    return ArenaCatalog.getArenaForTrophies(trophies);
  }

  // Calculate progress to next arena (0.0 to 1.0)
  double getProgressToNextArena(int trophies) {
    final current = getArena(trophies);
    if (current.maxTrophies == -1) return 1.0; // Max level

    final range = current.maxTrophies - current.minTrophies;
    final progress = trophies - current.minTrophies;
    
    // +1 because max is inclusive, e.g. 0-399 is 400 steps
    return (progress / (range + 1)).clamp(0.0, 1.0);
  }
}
