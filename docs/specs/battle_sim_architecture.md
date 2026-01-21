# Arquitetura de Simulação de Batalha: DuelForge

**Engine:** Flutter + Flame  
**Abordagem:** Simulação Determinística com Separação de View/State  
**Tick Rate:** 20 TPS (50ms por tick)

---

## 1. Conceito Central: Separação Simulação vs. Visualização
Para garantir determinismo e replays, a lógica do jogo (**Simulation**) roda separada da renderização (**View**).

*   **BattleSimulation (Logic):** Mantém o estado puro (dados). Roda em ticks fixos. Não sabe o que é um `Sprite` ou `Canvas`.
*   **BattleVisuals (Flame):** Lê o estado da `BattleSimulation` e desenha interpolações. Roda no `update(dt)` do Flame (60/120 FPS).

---

## 2. Loop de Update (Game Loop)
Utilizaremos um padrão de **Fixed Time Step** com acumulador.

```dart
class BattleEngine {
  final double tickRate = 1 / 20; // 0.05s (50ms)
  double _accumulator = 0.0;
  int _currentTick = 0;
  
  // Estado Atual (Single Source of Truth)
  BattleState state;
  
  // Buffer de Inputs (Ações dos jogadores agendadas para ticks futuros)
  List<PlayerAction> _pendingActions = [];

  void update(double dt) {
    _accumulator += dt;

    // Catch-up: roda a simulação tantas vezes quanto necessário para alcançar o tempo real
    while (_accumulator >= tickRate) {
      _processTick();
      _accumulator -= tickRate;
    }
    
    // Opcional: Calcular fator de interpolação (alpha) para renderização suave
    // double alpha = _accumulator / tickRate;
  }

  void _processTick() {
    // 1. Aplicar Inputs agendados para este tick
    _inputSystem.applyActions(state, _pendingActions, _currentTick);
    
    // 2. Executar Sistemas em Ordem
    _resourceSystem.update(state, tickRate);
    _statusSystem.update(state, tickRate);
    _targetingSystem.update(state);
    _combatSystem.update(state, tickRate);
    _projectileSystem.update(state, tickRate);
    _movementSystem.update(state, tickRate);
    _deathSystem.update(state);
    
    // 3. Finalizar Tick
    _currentTick++;
  }
}
```

---

## 3. Modelos de Dados (State)
Classes de dados puros (POJOs), preferencialmente imutáveis ou com cópia controlada para snapshots.

### `BattleState`
```dart
class BattleState {
  int tick;
  int rngSeed; // Estado atual do PRNG
  
  // Entidades
  Map<String, UnitState> units;
  Map<String, TowerState> towers;
  Map<String, ProjectileState> projectiles;
  
  // Jogadores
  PlayerState playerBlue;
  PlayerState playerRed;
}
```

### `UnitState`
```dart
class UnitState {
  final String id;
  final String ownerId;
  final String cardId; // Referência aos stats base (não duplicar dados estáticos)
  
  // Física
  Vector2 position;
  Vector2 velocity; // Para empurrões/knockback
  double rotation;
  
  // Combate
  double hp;
  String? targetId; // ID da unidade/torre alvo
  double attackCooldown; // Tempo restante para próximo ataque
  
  // Status
  List<StatusEffect> activeEffects; // [Poison, Slow, Stun]
  
  // Pathfinding
  int currentLane; // 0: Esquerda, 1: Direita
}
```

### `ProjectileState`
```dart
class ProjectileState {
  final String id;
  Vector2 position;
  String? targetUnitId; // Se for teleguiado
  Vector2? targetPos;   // Se for skillshot/area
  double speed;
  double damage;
  bool isAreaDamage;
}
```

---

## 4. Ordem de Execução dos Sistemas (Pipeline)

A ordem é crítica para evitar bugs como "unidade morta atacando" ou "unidade andando enquanto stunada".

1.  **InputSystem:**
    *   Processa `SpawnUnitAction` e `CastSpellAction`.
    *   Verifica custo de Elixir e validade da posição.
    *   Instancia novas entidades no `BattleState`.

2.  **ResourceSystem:**
    *   Incrementa Elixir dos jogadores (ex: +0.1 por tick).
    *   Gerencia regras de Overtime (2x Elixir).

3.  **StatusSystem:**
    *   Itera sobre `activeEffects`.
    *   Aplica dano de DoT (Poison).
    *   Reduz duração de efeitos. Remove expirados.
    *   Calcula modificadores atuais (ex: `speedMultiplier`, `isStunned`).

4.  **TargetingSystem:**
    *   Para cada unidade sem alvo (ou com alvo morto/fora de alcance):
    *   Busca inimigo mais próximo dentro do `aggroRange`.
    *   Define `targetId`.

5.  **CombatSystem:**
    *   Reduz `attackCooldown`.
    *   Se `cooldown <= 0` E `target` válido E `inRange`:
        *   Se Melee: Aplica dano instantâneo (cria evento `DamageEvent`).
        *   Se Ranged: Cria entidade `ProjectileState`.
        *   Reseta `attackCooldown`.

6.  **ProjectileSystem:**
    *   Move projéteis em direção ao alvo.
    *   Detecta colisão (distância < threshold).
    *   Ao colidir: Aplica dano/efeitos e marca projétil para remoção.

7.  **MovementSystem:**
    *   Se `isStunned`, pula.
    *   Se tem `target` e está fora de alcance: Move em direção ao alvo (Seek).
    *   Se não tem alvo: Move em direção ao waypoint da Lane (Flow Field).
    *   **Avoidance:** Aplica vetores de separação para evitar sobreposição com aliados (Soft Collision) e desviar de torres (Hard Collision).
    *   Atualiza `position`.

8.  **DeathSystem:**
    *   Verifica `hp <= 0`.
    *   Gera eventos de morte (para animações e recompensas).
    *   Remove entidades das listas do `BattleState`.

---

## 5. Telemetria e Replay

### Sistema de Replay
Como a simulação é determinística, não precisamos gravar o estado de cada frame. Gravamos apenas:
1.  **Seed Inicial:** O número usado para inicializar o `Random`.
2.  **Action Log:** Lista de inputs com o tick exato.

```json
// replay_match_123.json
{
  "seed": 987654321,
  "actions": [
    {"tick": 45, "player": "blue", "type": "SPAWN", "card": "archer", "x": 200, "y": 1600},
    {"tick": 120, "player": "red", "type": "SPELL", "card": "fireball", "x": 250, "y": 1500}
  ]
}
```
Para reproduzir: Reseta o `BattleState` com a seed e alimenta o `BattleEngine` com essas ações nos ticks específicos.

### Logs de Eventos (Telemetria)
Para debug e efeitos visuais (VFX), o `BattleEngine` deve emitir uma lista de eventos ocorridos no tick. O `BattleVisuals` consome isso.

```dart
enum BattleEventType { SPAWN, ATTACK, HIT, DIE, TOWER_DESTROYED }

class BattleEvent {
  final int tick;
  final BattleEventType type;
  final String entityId;
  final dynamic data; // Dano causado, posição, etc.
}
```

---

## 6. Implementação Prática: Próximos Passos

1.  Criar `lib/battle/sim/battle_state.dart` (Modelos).
2.  Criar `lib/battle/sim/battle_engine.dart` (Loop e Managers).
3.  Implementar o **ResourceSystem** e **InputSystem** primeiro (Spawnar coisas).
4.  Implementar **MovementSystem** básico (andar reto na lane).
5.  Conectar com o Flame: O `GameLoop` do Flame chama `engine.update(dt)` e depois atualiza os sprites baseados no `engine.state`.
