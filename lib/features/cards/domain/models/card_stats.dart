enum TargetType { ground, air, building, all }
enum DamageType { single, area, chain, dot, summonImpact }

abstract class CardStats {
  final int powerCost;
  final double cooldownSec;
  final List<TargetType> targets;
  final String role;
  final int components;

  const CardStats({
    required this.powerCost,
    required this.cooldownSec,
    required this.targets,
    required this.role,
    required this.components,
  });
}

class UnitStats extends CardStats {
  final double hitPoints;
  final double damagePerHit;
  final double attacksPerSecond;
  final double moveSpeedTilesPerSec;
  final double rangeTiles;
  final bool isMelee;
  final double projectileSpeedTilesPerSec;
  final double splashRadiusTiles;
  final double spawnDamage;
  final int chainMaxTargets;
  final double chainFalloffPercent;
  final double knockbackForce;
  final double stunSec;

  const UnitStats({
    required super.powerCost,
    required super.cooldownSec,
    required super.targets,
    required super.role,
    required super.components,
    required this.hitPoints,
    required this.damagePerHit,
    required this.attacksPerSecond,
    required this.moveSpeedTilesPerSec,
    required this.rangeTiles,
    required this.isMelee,
    this.projectileSpeedTilesPerSec = 0,
    this.splashRadiusTiles = 0,
    this.spawnDamage = 0,
    this.chainMaxTargets = 0,
    this.chainFalloffPercent = 0,
    this.knockbackForce = 0,
    this.stunSec = 0,
  });

  double get dps => damagePerHit * attacksPerSecond;
}

class SpellStats extends CardStats {
  final double durationSec;
  final double radiusTiles;
  final double tickIntervalSec;
  final double damagePerTick;
  final double damageInstant;
  final double spawnDamage;
  final double slowPercent;
  final double freezeSec;
  final int chainMaxTargets;
  final double chainFalloffPercent;

  const SpellStats({
    required super.powerCost,
    required super.cooldownSec,
    required super.targets,
    required super.role,
    required super.components,
    this.durationSec = 0,
    this.radiusTiles = 0,
    this.tickIntervalSec = 0,
    this.damagePerTick = 0,
    this.damageInstant = 0,
    this.spawnDamage = 0,
    this.slowPercent = 0,
    this.freezeSec = 0,
    this.chainMaxTargets = 0,
    this.chainFalloffPercent = 0,
  });

  double get dps => tickIntervalSec > 0 ? damagePerTick / tickIntervalSec : 0;
}

class BuildingStats extends CardStats {
  final double hitPoints;
  final double lifetimeSec;
  final bool canAttack;
  final double damagePerHit;
  final double attacksPerSecond;
  final double rangeTiles;
  final double projectileSpeedTilesPerSec;
  final double splashRadiusTiles;
  final double spawnDamage;
  final bool taunt;
  final int spawnUnits;
  final double spawnIntervalSec;

  const BuildingStats({
    required super.powerCost,
    required super.cooldownSec,
    required super.targets,
    required super.role,
    required super.components,
    required this.hitPoints,
    required this.lifetimeSec,
    this.canAttack = false,
    this.damagePerHit = 0,
    this.attacksPerSecond = 0,
    this.rangeTiles = 0,
    this.projectileSpeedTilesPerSec = 0,
    this.splashRadiusTiles = 0,
    this.spawnDamage = 0,
    this.taunt = false,
    this.spawnUnits = 0,
    this.spawnIntervalSec = 0,
  });

  double get dps => attacksPerSecond > 0 ? damagePerHit * attacksPerSecond : 0;
}
