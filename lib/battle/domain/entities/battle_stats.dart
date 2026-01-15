
class BattleStats {
  final int hp;
  final int damage;
  final double dps;
  final double range;
  final double speed; // 1.15 (fast), 1.0 (medium), 0.85 (slow)
  final double attackSpeed;
  final double? radius;
  final double? duration;
  final int spawnCount;
  final String targets; // "ground", "air", "both", "none"
  final List<String> effects;
  final double deployTime;

  const BattleStats({
    this.hp = 0,
    this.damage = 0,
    this.dps = 0.0,
    this.range = 0.0,
    this.speed = 0.0,
    this.attackSpeed = 1.0,
    this.radius,
    this.duration,
    this.spawnCount = 1,
    this.targets = "none",
    this.effects = const [],
    this.deployTime = 1.0,
  });

  BattleStats copyWith({
    int? hp,
    int? damage,
    double? dps,
    double? range,
    double? speed,
    double? attackSpeed,
    double? radius,
    double? duration,
    int? spawnCount,
    String? targets,
    List<String>? effects,
    double? deployTime,
  }) {
    return BattleStats(
      hp: hp ?? this.hp,
      damage: damage ?? this.damage,
      dps: dps ?? this.dps,
      range: range ?? this.range,
      speed: speed ?? this.speed,
      attackSpeed: attackSpeed ?? this.attackSpeed,
      radius: radius ?? this.radius,
      duration: duration ?? this.duration,
      spawnCount: spawnCount ?? this.spawnCount,
      targets: targets ?? this.targets,
      effects: effects ?? this.effects,
      deployTime: deployTime ?? this.deployTime,
    );
  }

  @override
  String toString() {
    return 'BattleStats(hp: $hp, dmg: $damage, dps: ${dps.toStringAsFixed(1)}, range: $range, speed: $speed)';
  }
}
