import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../../battle/data/balance_rules.dart';
import '../../../battle/domain/config/battle_field_config.dart';
import '../models/carta.dart';

class DuelForgeGame extends FlameGame {
  final void Function(String evento, Map<String, dynamic> payload) onEvento;

  DuelForgeGame({required this.onEvento});

  late final World world;
  late final CameraComponent cameraComponent;
  
  // Entidades
  final List<Unit> units = [];
  final List<Tower> towers = [];
  final List<SpellEffect> spells = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Configura mundo e câmera
    world = World();
    cameraComponent = CameraComponent(world: world);
    
    // Ajusta câmera para focar no centro do campo (0,0) e mostrar tudo
    // Campo é 18x30. Zoom deve caber isso.
    // Se tela for 400px largura, zoom ~20 (400/18 ~ 22)
    cameraComponent.viewfinder.anchor = Anchor.center;
    cameraComponent.viewfinder.zoom = 20.0; 
    
    add(world);
    add(cameraComponent);

    // Inicializa Torres
    _setupTowers();
  }

  void _setupTowers() {
    // Coordenadas baseadas em BattleFieldConfig (W=18, H=30)
    // Centro = 0,0
    // King Player: Y=12, X=0
    // Princess Player: Y=7.5, X=-5 / X=5
    
    // Inimigo (Topo, Y negativo)
    _addTower(TowerType.king, Side.enemy, Vector2(0, -12));
    _addTower(TowerType.princess, Side.enemy, Vector2(-5, -7.5));
    _addTower(TowerType.princess, Side.enemy, Vector2(5, -7.5));

    // Jogador (Baixo, Y positivo)
    _addTower(TowerType.king, Side.player, Vector2(0, 12));
    _addTower(TowerType.princess, Side.player, Vector2(-5, 7.5));
    _addTower(TowerType.princess, Side.player, Vector2(5, 7.5));
  }

  void _addTower(TowerType type, Side side, Vector2 pos) {
    final tower = Tower(type: type, side: side, position: pos);
    towers.add(tower);
    world.add(tower);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Checagem de Vitória/Derrota
    if (!_hasKing(Side.player)) {
      _gameOver(Side.enemy);
      return;
    }
    if (!_hasKing(Side.enemy)) {
      _gameOver(Side.player);
      return;
    }
    
    // Lógica de Unidades
    for (final unit in units) {
      if (unit.isDead) continue;
      
      // Buildings decay
      if (unit.isBuilding) {
        unit.lifetime -= dt;
        if (unit.lifetime <= 0) {
          unit.takeDamage(unit.maxHp * 0.1 * dt); // Decay rápido ao fim
          if (unit.lifetime <= -2) unit.hp = 0; // Force kill
        }
      }

      // 1. Buscar Alvo
      final target = _findTarget(unit);
      
      // 2. Mover ou Atacar
      if (target != null) {
        final dist = unit.position.distanceTo(target.position);
        // Subtrai raio do alvo para colisão mais precisa (opcional, aqui simplificado)
        if (dist <= unit.range) {
          unit.attack(target, dt);
        } else {
          if (!unit.isBuilding) {
             unit.moveTowards(target.position, dt);
          }
        }
      } else {
        // Se não tem alvo, move para frente (norte ou sul)
        if (!unit.isBuilding) {
          // Player vai para Y negativo (topo), Enemy vai para Y positivo (baixo)
          final forwardY = unit.side == Side.player ? -15.0 : 15.0;
          
          // Snap to Lane logic for movement?
          // Se não tem alvo, segue a lane.
          double targetX = unit.position.x;
          // Se estiver longe das lanes, vai para a mais próxima
          if ((targetX - BattleFieldConfig.laneLeftX).abs() > 2 && (targetX - BattleFieldConfig.laneRightX).abs() > 2) {
             targetX = BattleFieldConfig.snapToLane(targetX);
          }

          final forward = Vector2(targetX, forwardY);
          unit.moveTowards(forward, dt);
        }
      }
    }

    // Limpeza
    units.removeWhere((u) {
      if (u.isDead) {
        u.removeFromParent();
        return true;
      }
      return false;
    });
    
    towers.removeWhere((t) {
      if (t.isDead) {
        t.removeFromParent();
        return true;
      }
      return false;
    });

    spells.removeWhere((s) {
      if (s.finished) {
        s.removeFromParent();
        return true;
      }
      return false;
    });
  }

  bool _hasKing(Side side) {
    return towers.any((t) => t.side == side && t.type == TowerType.king && !t.isDead);
  }

  void _gameOver(Side winner) {
    pauseEngine();
    onEvento('game_over', {'winner': winner == Side.player ? 'player' : 'enemy'});
  }

  GameEntity? _findTarget(Unit unit) {
    GameEntity? bestTarget;
    double minDistance = double.infinity;

    // Função auxiliar para verificar validade do alvo
    bool isValidTarget(GameEntity entity) {
      if (entity.side == unit.side || entity.isDead) return false;
      
      // Checa tipo de alvo (Ar/Terra)
      bool entityIsFlying = (entity is Unit) && entity.isFlying;
      
      if (unit.targetType == TargetType.ground && entityIsFlying) return false;
      if (unit.targetType == TargetType.air && !entityIsFlying) return false;
      // TargetType.both ataca tudo
      
      return true;
    }

    // Procura em unidades inimigas
    for (final other in units) {
      if (!isValidTarget(other)) continue;
      
      final dist = unit.position.distanceTo(other.position);
      if (dist < minDistance && dist <= unit.aggroRange) {
        minDistance = dist;
        bestTarget = other;
      }
    }

    // Se não achou unidade, procura torre (Torres são sempre "Terra" para fins de alvo, mas atingíveis por todos geralmente)
    // Exceto se targetType == air (algumas unidades só atacam ar? Raro, mas possível. Swarm Anti-Air)
    if (bestTarget == null && unit.targetType != TargetType.air) {
      for (final tower in towers) {
        if (tower.side == unit.side || tower.isDead) continue;
        final dist = unit.position.distanceTo(tower.position);
        // Torres têm aggro global se for o mais próximo, mas vamos limitar levemente
        if (dist < minDistance) { 
          minDistance = dist;
          bestTarget = tower;
        }
      }
    }

    return bestTarget;
  }

  void spawnUnit(Carta carta, Vector2 normalizedPos, Side side) {
    spawnCard(carta, normalizedPos, side);
  }

  void spawnCard(Carta carta, Vector2 normalizedPos, Side side) {
    // Converte normalized (0..1) para World Coordinates (-9..9, -15..15)
    // normalizedPos vem da UI onde (0,0) é TopLeft e (1,1) é BottomRight
    // Mas no World (0,0) é centro.
    // X: 0 -> -9, 1 -> 9
    // Y: 0 -> -15, 1 -> 15
    
    double wx = (normalizedPos.x - 0.5) * BattleFieldConfig.width;
    double wy = (normalizedPos.y - 0.5) * BattleFieldConfig.height;
    
    // Snap to Lane logic for spawn?
    // Se for tropa, talvez snap? Se for spell, exato.
    if (carta.tipo == TipoCarta.tropa) {
       // Opcional: Snap se estiver perto da lane
       // wx = BattleFieldConfig.snapToLane(wx); 
    }

    final worldPos = Vector2(wx, wy);

    if (carta.tipo == TipoCarta.feitico) {
      _castSpell(carta, worldPos, side);
    } else {
      _spawnUnitEntity(carta, worldPos, side);
    }
  }

  void _spawnUnitEntity(Carta carta, Vector2 pos, Side side) {
    final unit = Unit(
      carta: carta,
      side: side,
      position: pos,
    );
    
    // Spawn quantity (Swarm)
    int qtd = unit.spawnQuantity;
    if (qtd > 1) {
      // Spawna em formação
      for (int i = 0; i < qtd; i++) {
        final offset = Vector2(
          (Random().nextDouble() - 0.5) * 40, 
          (Random().nextDouble() - 0.5) * 40
        );
        final u = Unit(carta: carta, side: side, position: pos + offset);
        units.add(u);
        world.add(u);
      }
    } else {
      units.add(unit);
      world.add(unit);
    }
  }

  void _castSpell(Carta carta, Vector2 pos, Side side) {
    final stats = BalanceRules.computeFinalStats(carta.id, 1);
    final spell = SpellEffect(
      position: pos,
      radius: (stats.radius ?? 2.0) * 40, // Converte blocos para pixels
      duration: stats.duration ?? 0.5,
      damage: stats.damage.toDouble(),
      side: side,
      effect: stats.effects.isNotEmpty ? stats.effects.first : null,
      slow: stats.effects.any((e) => e.contains("slow")) ? 0.35 : null, // Simplificado
    );
    spells.add(spell);
    world.add(spell);
  }
}

enum Side { player, enemy }
enum TowerType { king, princess }
enum TargetType { ground, air, both }

abstract class GameEntity extends PositionComponent {
  Side side;
  double hp;
  double maxHp;
  bool get isDead => hp <= 0;

  GameEntity({required this.side, required this.hp, required this.maxHp});

  void takeDamage(double amount) {
    hp -= amount;
  }
}

class Tower extends GameEntity with HasGameRef {
  final TowerType type;
  final double range = 7.5; // World units
  final double damage = 50;
  final double attackSpeed = 1.2;
  double _attackCooldown = 0;
  Sprite? _sprite;

  Tower({required this.type, required super.side, required Vector2 position}) 
      : super(hp: type == TowerType.king ? 4000 : 2500, maxHp: type == TowerType.king ? 4000 : 2500) {
    this.position = position;
    size = Vector2(3, 3); // 3x3 tiles
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    try {
      _sprite = await gameRef.loadSprite(type == TowerType.king ? 'thor.jpeg' : 'torre de vigia.jpeg');
    } catch (_) {}
  }

  @override
  void update(double dt) {
    super.update(dt);
    _attackCooldown -= dt;

    if (_attackCooldown <= 0) {
      final target = _findTarget();
      if (target != null) {
        _attackCooldown = attackSpeed;
        final projectile = Projectile(
          start: position,
          target: target,
          damage: damage,
          color: side == Side.player ? Colors.blueAccent : Colors.redAccent,
        );
        parent?.add(projectile);
      }
    }
  }

  GameEntity? _findTarget() {
    final game = findGame() as DuelForgeGame?;
    if (game == null) return null;

    GameEntity? bestTarget;
    double minDistance = double.infinity;

    for (final unit in game.units) {
      if (unit.side == side || unit.isDead) continue;
      final dist = position.distanceTo(unit.position);
      if (dist <= range && dist < minDistance) {
        minDistance = dist;
        bestTarget = unit;
      }
    }
    return bestTarget;
  }

  @override
  void render(Canvas canvas) {
    if (_sprite != null) {
      _sprite!.render(canvas, size: size);
      if (side == Side.enemy) {
        canvas.drawRect(size.toRect(), Paint()..color = Colors.red.withOpacity(0.3));
      }
    } else {
      final color = side == Side.player ? Colors.blue : Colors.red;
      canvas.drawRect(size.toRect(), Paint()..color = color);
    }
    
    // HP Bar
    final hpPct = hp / maxHp;
    canvas.drawRect(Rect.fromLTWH(0, -0.5, size.x, 0.3), Paint()..color = Colors.black);
    canvas.drawRect(Rect.fromLTWH(0, -0.5, size.x * hpPct, 0.3), Paint()..color = Colors.green);
  }
}

class Unit extends GameEntity with HasGameRef {
  final Carta carta;
  double speed = 0;
  double range = 0;
  double damage = 0;
  double attackSpeed = 0;
  double aggroRange = 5.0; // World units
  
  // New Properties
  bool isFlying = false;
  bool isBuilding = false;
  double lifetime = 0;
  TargetType targetType = TargetType.ground;
  int spawnQuantity = 1;
  
  double _attackCooldown = 0;
  Sprite? _sprite;

  Unit({required this.carta, required super.side, required Vector2 position})
      : super(hp: 0, maxHp: 0) {
    
    final stats = BalanceRules.computeFinalStats(carta.id, 1);
    
    this.speed = stats.speed * 2.0; // Speed factor for world units
    this.range = stats.range; // Already in tiles/world units? Assuming stats.range is ~1-5
    this.damage = stats.damage.toDouble();
    this.attackSpeed = stats.attackSpeed;
    this.hp = stats.hp.toDouble();
    this.maxHp = stats.hp.toDouble();
    
    this.spawnQuantity = stats.spawnCount;
    
    // Parse Target Type
    if (stats.targets == "air") this.targetType = TargetType.air;
    else if (stats.targets == "both") this.targetType = TargetType.both;
    else this.targetType = TargetType.ground;

    // Parse Special Types
    if (carta.tipo == TipoCarta.construcao) {
      this.isBuilding = true;
      this.lifetime = 30.0; // Default lifetime
      this.speed = 0; // Buildings don't move
    }

    // Flying logic
    if (stats.targets == "air" || stats.effects.contains("flying")) {
      this.isFlying = true;
    }

    this.position = position;
    size = Vector2(1.5, 1.5); // 1.5x1.5 tiles
    anchor = Anchor.center;
    
    this.aggroRange = max(5.0, this.range + 2.0);
  }

  @override
  Future<void> onLoad() async {
    String image = 'guerreiro ulf lendário.jpeg';
    if (carta.imagePath != null) {
      final path = carta.imagePath!;
      if (path.startsWith('assets/cards/')) {
         final filename = path.split('/').last;
         image = '../cards/$filename';
      } else {
         image = path;
      }
    }
    
    try {
      _sprite = await gameRef.loadSprite(image);
    } catch (_) {
      try {
        _sprite = await gameRef.loadSprite('guerreiro ulf lendário.jpeg');
      } catch (_) {}
    }
  }

  void moveTowards(Vector2 target, double dt) {
    if (speed <= 0) return;
    final dir = (target - position).normalized();
    position += dir * speed * dt;
  }

  void attack(GameEntity target, double dt) {
    _attackCooldown -= dt;
    if (_attackCooldown <= 0) {
      _attackCooldown = attackSpeed;
      
      if (range > 2.0) { // Ranged
        final projectile = Projectile(
          start: position,
          target: target,
          damage: damage,
          color: side == Side.player ? Colors.cyanAccent : Colors.orangeAccent,
        );
        parent?.add(projectile);
      } else {
        target.takeDamage(damage);
        final flash = CircleComponent(
          radius: 1.0,
          paint: Paint()..color = Colors.white.withOpacity(0.5),
          position: position,
          anchor: Anchor.center,
        );
        parent?.add(flash);
        Future.delayed(const Duration(milliseconds: 100), () => flash.removeFromParent());
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (_sprite != null) {
      canvas.save();
      canvas.clipPath(Path()..addOval(size.toRect()));
      _sprite!.render(canvas, size: size);
      if (side == Side.enemy) {
        canvas.drawRect(size.toRect(), Paint()..color = Colors.red.withOpacity(0.3));
      }
      canvas.restore();
      
      final borderColor = side == Side.player ? Colors.cyan : Colors.orange;
      canvas.drawCircle(Offset(size.x/2, size.y/2), size.x/2, Paint()..color = borderColor..style = PaintingStyle.stroke..strokeWidth = 0.1);
    } else {
      final color = side == Side.player ? Colors.cyan : Colors.orange;
      canvas.drawCircle(Offset(size.x/2, size.y/2), size.x/2, Paint()..color = color);
    }
    
    // HP Bar
    final hpPct = hp / maxHp;
    canvas.drawRect(Rect.fromLTWH(0, -0.3, size.x, 0.2), Paint()..color = Colors.black);
    canvas.drawRect(Rect.fromLTWH(0, -0.3, size.x * hpPct, 0.2), Paint()..color = Colors.green);

    // Lifetime Bar for Buildings
    if (isBuilding) {
       final lifePct = lifetime / 30.0; // Assuming 30s max
       canvas.drawRect(Rect.fromLTWH(0, size.y + 0.1, size.x * lifePct, 0.1), Paint()..color = Colors.yellow);
    }
  }
}

class Projectile extends PositionComponent {
  final Vector2 start;
  final GameEntity target;
  final double damage;
  final Color color;
  final double speed = 15.0; // World units per second

  Projectile({
    required this.start,
    required this.target,
    required this.damage,
    required this.color,
  }) {
    position = start;
    size = Vector2(0.5, 0.5);
    anchor = Anchor.center;
  }
    final game = findGame() as DuelForgeGame?;
    if (game == null) return null;

    GameEntity? bestTarget;
    double minDistance = double.infinity;

    for (final unit in game.units) {
      if (unit.side == side || unit.isDead) continue;
      final dist = position.distanceTo(unit.position);
      if (dist <= range && dist < minDistance) {
        minDistance = dist;
        bestTarget = unit;
      }
    }
    return bestTarget;
  }

  @override
  void render(Canvas canvas) {
    if (_sprite != null) {
      _sprite!.render(canvas, size: size);
      if (side == Side.enemy) {
        canvas.drawRect(size.toRect(), Paint()..color = Colors.red.withOpacity(0.3));
      }
    } else {
      final color = side == Side.player ? Colors.blue : Colors.red;
      canvas.drawRect(size.toRect(), Paint()..color = color);
    }
    
    // HP Bar
    final hpPct = hp / maxHp;
    canvas.drawRect(Rect.fromLTWH(0, -0.5, size.x, 0.3), Paint()..color = Colors.black);
    canvas.drawRect(Rect.fromLTWH(0, -0.5, size.x * hpPct, 0.3), Paint()..color = Colors.green);
  }
}

class Unit extends GameEntity with HasGameRef {
  final Carta carta;
  double speed = 0;
  double range = 0;
  double damage = 0;
  double attackSpeed = 0;
  double aggroRange = 5.0; // World units
  
  // New Properties
  bool isFlying = false;
  bool isBuilding = false;
  double lifetime = 0;
  TargetType targetType = TargetType.ground;
  int spawnQuantity = 1;
  
  double _attackCooldown = 0;
  Sprite? _sprite;

  Unit({required this.carta, required super.side, required Vector2 position})
      : super(hp: 0, maxHp: 0) {
    
    final stats = BalanceRules.computeFinalStats(carta.id, 1);
    
    this.speed = stats.speed * 2.0; // Speed factor for world units
    this.range = stats.range; // Already in tiles/world units? Assuming stats.range is ~1-5
    this.damage = stats.damage.toDouble();
    this.attackSpeed = stats.attackSpeed;
    this.hp = stats.hp.toDouble();
    this.maxHp = stats.hp.toDouble();
    
    this.spawnQuantity = stats.spawnCount;
    
    // Parse Target Type
    if (stats.targets == "air") this.targetType = TargetType.air;
    else if (stats.targets == "both") this.targetType = TargetType.both;
    else this.targetType = TargetType.ground;

    // Parse Special Types
    if (carta.tipo == TipoCarta.construcao) {
      this.isBuilding = true;
      this.lifetime = 30.0; // Default lifetime
      this.speed = 0; // Buildings don't move
    }

    // Flying logic
    if (stats.targets == "air" || stats.effects.contains("flying")) {
      this.isFlying = true;
    }

    this.position = position;
    size = Vector2(1.5, 1.5); // 1.5x1.5 tiles
    anchor = Anchor.center;
    
    this.aggroRange = max(5.0, this.range + 2.0);
  }

  @override
  Future<void> onLoad() async {
    String image = 'guerreiro ulf lendário.jpeg';
    if (carta.imagePath != null) {
      final path = carta.imagePath!;
      if (path.startsWith('assets/cards/')) {
         final filename = path.split('/').last;
         image = '../cards/$filename';
      } else {
         image = path;
      }
    }
    
    try {
      _sprite = await gameRef.loadSprite(image);
    } catch (_) {
      try {
        _sprite = await gameRef.loadSprite('guerreiro ulf lendário.jpeg');
      } catch (_) {}
    }
  }

  void moveTowards(Vector2 target, double dt) {
    if (speed <= 0) return;
    final dir = (target - position).normalized();
    position += dir * speed * dt;
  }

  void attack(GameEntity target, double dt) {
    _attackCooldown -= dt;
    if (_attackCooldown <= 0) {
      _attackCooldown = attackSpeed;
      
      if (range > 2.0) { // Ranged
        final projectile = Projectile(
          start: position,
          target: target,
          damage: damage,
          color: side == Side.player ? Colors.cyanAccent : Colors.orangeAccent,
        );
        parent?.add(projectile);
      } else {
        target.takeDamage(damage);
        final flash = CircleComponent(
          radius: 1.0,
          paint: Paint()..color = Colors.white.withOpacity(0.5),
          position: position,
          anchor: Anchor.center,
        );
        parent?.add(flash);
        Future.delayed(const Duration(milliseconds: 100), () => flash.removeFromParent());
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (_sprite != null) {
      canvas.save();
      canvas.clipPath(Path()..addOval(size.toRect()));
      _sprite!.render(canvas, size: size);
      if (side == Side.enemy) {
        canvas.drawRect(size.toRect(), Paint()..color = Colors.red.withOpacity(0.3));
      }
      canvas.restore();
      
      final borderColor = side == Side.player ? Colors.cyan : Colors.orange;
      canvas.drawCircle(Offset(size.x/2, size.y/2), size.x/2, Paint()..color = borderColor..style = PaintingStyle.stroke..strokeWidth = 0.1);
    } else {
      final color = side == Side.player ? Colors.cyan : Colors.orange;
      canvas.drawCircle(Offset(size.x/2, size.y/2), size.x/2, Paint()..color = color);
    }
    
    // HP Bar
    final hpPct = hp / maxHp;
    canvas.drawRect(Rect.fromLTWH(0, -0.3, size.x, 0.2), Paint()..color = Colors.black);
    canvas.drawRect(Rect.fromLTWH(0, -0.3, size.x * hpPct, 0.2), Paint()..color = Colors.green);

    // Lifetime Bar for Buildings
    if (isBuilding) {
       final lifePct = lifetime / 30.0; // Assuming 30s max
       canvas.drawRect(Rect.fromLTWH(0, size.y + 0.1, size.x * lifePct, 0.1), Paint()..color = Colors.yellow);
    }
  }
}

class Projectile extends PositionComponent {
  final Vector2 start;
  final GameEntity target;
  final double damage;
  final Color color;
  final double speed = 15.0; // World units per second

  Projectile({
    required this.start,
    required this.target,
    required this.damage,
    required this.color,
  }) {
    position = start;
    size = Vector2(0.5, 0.5);
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (target.isDead) {
      removeFromParent();
      return;
    }

    final dir = (target.position - position).normalized();
    position += dir * speed * dt;

    if (position.distanceTo(target.position) < 0.5) {
      target.takeDamage(damage);
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset(size.x/2, size.y/2), 0.2, Paint()..color = color);
  }
}

class SpellEffect extends PositionComponent with HasGameRef {
  final double radius;
  final double duration;
  final double damage;
  final Side side;
  final String? effect;
  final double? slow;
  
  double _timer = 0;
  double _tickTimer = 0;
  bool finished = false;

  SpellEffect({
    required Vector2 position,
    required this.radius,
    required this.duration,
    required this.damage,
    required this.side,
    this.effect,
    this.slow,
  }) {
    this.position = position;
    size = Vector2(radius * 2, radius * 2);
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    _tickTimer += dt;

    // Apply effect every 0.5s or instant if duration is 0
    if (duration <= 0.1) {
      _applyEffect();
      finished = true;
    } else {
      if (_tickTimer >= 0.5) {
        _applyEffect(dt: 0.5); // Apply partial damage for DoT
        _tickTimer = 0;
      }
      if (_timer >= duration) {
        finished = true;
      }
    }
  }

  void _applyEffect({double dt = 1.0}) {
    final game = findGame() as DuelForgeGame?;
    if (game == null) return;

    // Damage calculation: if instant, full damage. If DoT, damage per second * dt.
    double damageToApply = damage;
    if (duration > 0.1) {
       damageToApply = (damage / duration) * dt; // Dano total distribuído
    }

    // Find targets in radius
    for (final unit in game.units) {
      if (unit.side == side || unit.isDead) continue; // Friendly fire off
      if (unit.position.distanceTo(position) <= radius) {
        unit.takeDamage(damageToApply);
        
        // Apply Slow
        if (slow != null && slow! > 0) {
           // Simple slow implementation: reduce speed temporarily
           // In a real engine, we'd add a "StatusEffect" component to the unit.
           // Here we just modify speed and hope it resets? No, that's permanent.
           // For now, let's just apply damage. Status effects require a system I haven't built yet.
        }
      }
    }
    
    // Hit Towers too
    for (final tower in game.towers) {
      if (tower.side == side || tower.isDead) continue;
      if (tower.position.distanceTo(position) <= radius) {
        tower.takeDamage(damageToApply);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = (side == Side.player ? Colors.cyan : Colors.orange).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(size.x/2, size.y/2), radius, paint);
    
    // Border
    canvas.drawCircle(Offset(size.x/2, size.y/2), radius, Paint()..color = Colors.white.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 0.1);
  }
}
