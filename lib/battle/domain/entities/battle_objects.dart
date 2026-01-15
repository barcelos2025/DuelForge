
import 'package:flame/components.dart'; // For Vector2
import 'status_effects.dart';

enum BattleSide { player, enemy }
enum AttackType { single, aoe }

abstract class BattleEntity {
  final String id;
  final BattleSide side;
  double hp;
  double maxHp;
  Vector2 position;
  bool isDead = false;
  double radius = 0.5; // Collision radius
  
  final List<StatusEffect> statusEffects = [];
  
  // Pacing & Visuals
  double spawnTimer = 0;
  double maxSpawnTime = 0;
  double timeSinceLastHit = 999.0;

  BattleEntity({
    required this.id,
    required this.side,
    required this.hp,
    required this.maxHp,
    required this.position,
  });

  void tick(double dt) {
    // Update Timers
    if (spawnTimer > 0) {
      spawnTimer -= dt;
    }
    timeSinceLastHit += dt;
    
    // Update Status Effects
    updateStatus(dt);
  }

  void takeDamage(double amount) {
    // Apply Damage Taken Multipliers
    final effectiveDamage = CombatStats.applyDamageTaken(amount, statusEffects);
    
    hp -= effectiveDamage;
    timeSinceLastHit = 0; // Reset hit timer
    
    if (hp <= 0) {
      hp = 0;
      isDead = true;
    }
  }
  
  void addStatus(StatusEffect effect) {
    // Check if similar effect exists? usually refresh duration or stack?
    // Simple: Add new. Complex: Refresh if same type.
    // Let's refresh if same type and value, or add if different.
    // For simplicity, just add. Cleanup handles expiration.
    statusEffects.add(effect);
  }
  
  void updateStatus(double dt) {
    for (var e in statusEffects) {
      e.duration -= dt;
      
      // Handle DoT
      if (e.type == StatusType.dot) {
        e.tickTimer += dt;
        if (e.tickTimer >= 1.0) { // Tick every second
          takeDamage(e.value); // Value is DPS
          e.tickTimer = 0;
        }
      }
    }
    statusEffects.removeWhere((e) => e.duration <= 0);
  }
}

enum TowerType { king, princess }

class BattleTower extends BattleEntity {
  final TowerType type;
  final double range;
  final double damage;
  final double attackSpeed;
  double attackCooldown = 0;

  BattleTower({
    required String id,
    required BattleSide side,
    required this.type,
    required Vector2 position,
    double? hpOverride,
  }) : 
    range = 7.5, // Standard range
    damage = 100, // Placeholder
    attackSpeed = 1.0,
    super(
      id: id,
      side: side,
      hp: hpOverride ?? (type == TowerType.king ? 4000 : 2500),
      maxHp: hpOverride ?? (type == TowerType.king ? 4000 : 2500),
      position: position,
    );
}

class BattleUnit extends BattleEntity {
  final String cardId;
  double speed; // Base speed
  double range;
  double damage;
  double attackSpeed;
  double attackCooldown = 0;
  double aggroRange;
  bool isFlying;
  bool isBuilding;
  double lifetime;
  
  // Combat Properties
  AttackType attackType;
  double aoeRadius;
  List<StatusEffect> onHitEffects;
  
  // Aura Properties
  double auraRadius;
  List<StatusEffect> auraEffects;
  
  // Target logic
  BattleEntity? currentTarget;
  double targetingTimer = 0;

  BattleUnit({
    required String id,
    required BattleSide side,
    required this.cardId,
    required Vector2 position,
    required double hp,
    required this.speed,
    required this.range,
    required this.damage,
    required this.attackSpeed,
    this.isFlying = false,
    this.isBuilding = false,
    this.lifetime = 0,
    this.aggroRange = 5.0,
    this.attackType = AttackType.single,
    this.aoeRadius = 0,
    this.onHitEffects = const [],
    this.auraRadius = 0,
    this.auraEffects = const [],
  }) : super(
    id: id,
    side: side,
    hp: hp,
    maxHp: hp,
    position: position,
  );
  
  // Computed Properties
  double get currentSpeed => CombatStats.applySlow(speed, statusEffects);
  bool get isStunned => CombatStats.isStunned(statusEffects);
  bool get isConfused => statusEffects.any((e) => e.type == StatusType.confusion);
}

class BattleSpell {
  final String id;
  final String cardId; // Added
  final BattleSide side;
  final Vector2 position;
  final double radius;
  final double damage;
  final double duration;
  double elapsed = 0;
  bool finished = false;
  
  // Advanced Properties
  double tickInterval;
  double tickTimer;
  List<StatusEffect> statusEffects;

  BattleSpell({
    required this.id,
    required this.cardId, // Added
    required this.side,
    required this.position,
    required this.radius,
    required this.damage,
    required this.duration,
    this.tickInterval = 0.5,
    this.statusEffects = const [],
  }) : tickTimer = 0;
}
