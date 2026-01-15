
enum StatusType { slow, stun, damageTaken, dot, confusion }

class StatusEffect {
  final StatusType type;
  final double value; // magnitude (e.g. 0.15 for 15% slow)
  double duration;
  double tickTimer = 0; // For DoT

  StatusEffect({
    required this.type,
    required this.value,
    required this.duration,
  });
}

class CombatStats {
  // Helper to calculate effective stats
  static double applySlow(double baseSpeed, List<StatusEffect> effects) {
    double multiplier = 1.0;
    for (var e in effects) {
      if (e.type == StatusType.slow) {
        multiplier *= (1.0 - e.value);
      }
    }
    // Stun = 0 speed
    if (effects.any((e) => e.type == StatusType.stun)) return 0;
    
    return baseSpeed * multiplier;
  }

  static double applyDamageTaken(double damage, List<StatusEffect> effects) {
    double multiplier = 1.0;
    for (var e in effects) {
      if (e.type == StatusType.damageTaken) {
        multiplier += e.value;
      }
    }
    return damage * multiplier;
  }
  
  static bool isStunned(List<StatusEffect> effects) {
    return effects.any((e) => e.type == StatusType.stun);
  }
}
