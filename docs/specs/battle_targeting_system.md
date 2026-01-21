# Especificação do Sistema de Aquisição de Alvo (Targeting)

**Contexto:** DuelForge (Combate Tático em Tempo Real)  
**Responsabilidade:** Determinar qual entidade inimiga uma unidade ou torre deve atacar a cada tick.

---

## 1. Definições e Tipos

### Tipos de Movimento (MovementType)
*   **GROUND:** Caminha pelo chão (Viking, Gigante). Bloqueado por rio/buracos.
*   **AIR:** Voa (Dragão, Valquíria Alada). Ignora terreno.
*   **STRUCTURE:** Imóvel (Torres, Construções).

### Tipos de Ataque (AttackCapability)
*   **MELEE:** Alcance curto (< 1.5u). Dano físico.
*   **RANGED:** Alcance longo (> 2.0u). Projéteis.
*   **SIEGE:** Foca apenas construções.

### Filtros de Alvo (TargetMask)
Define o que a unidade *pode* atingir.
*   `GROUND_ONLY`: Apenas unidades terrestres e construções.
*   `AIR_ONLY`: Apenas unidades aéreas.
*   `BOTH`: Terrestre e Aéreo.
*   `BUILDING_ONLY`: Ignora tropas, foca apenas Torres e Construções.

---

## 2. Matriz de Targeting

| Unidade (Exemplo) | Tipo Mov. | Cap. Ataque | Target Mask | Comportamento |
| :--- | :--- | :--- | :--- | :--- |
| **Guerreiro Nórdico** | Ground | Melee | Ground Only | Ataca o inimigo terrestre mais próximo. Ignora aéreos. |
| **Arqueira Élfica** | Ground | Ranged | Both | Ataca qualquer inimigo no alcance. Prioriza o mais próximo. |
| **Gigante de Gelo** | Ground | Melee | **Building Only** | Ignora todas as tropas. Caminha direto para a construção mais próxima. |
| **Wyvern (Dragão)** | Air | Ranged | Both | Voa e ataca qualquer coisa. |
| **Torre Rúnica** | Structure | Ranged | Both | Defesa estática. Ataca qualquer coisa no raio. |

---

## 3. Algoritmo de Seleção (Pseudocódigo)

O algoritmo roda no `TargetingSystem` a cada tick (ou a cada N ticks para otimização) para unidades que estão `State.IDLE` ou `State.SEARCHING`.

```dart
Unit? findBestTarget(Unit source, BattleState state) {
  // 1. Lista de Candidatos
  // Otimização: Usar SpatialHash ou QuadTree para pegar apenas inimigos próximos
  var enemies = state.getEnemiesOf(source.owner);
  
  Unit? bestTarget = null;
  double minDistanceSq = double.infinity;
  
  // Raio de Visão (Aggro Range) vs Raio de Ataque (Attack Range)
  // Normalmente Aggro >= Attack.
  double searchRadiusSq = source.aggroRange * source.aggroRange;

  for (var enemy in enemies) {
    // --- FILTROS RÁPIDOS ---
    
    // A. Está vivo?
    if (enemy.isDead || enemy.isInvulnerable) continue;
    
    // B. É visível? (Stealth check)
    if (enemy.isHidden) continue;
    
    // C. Tipo compatível? (Air/Ground check)
    if (!canHit(source.targetMask, enemy.movementType)) continue;

    // --- CÁLCULO DE DISTÂNCIA ---
    double distSq = source.position.distanceToSquared(enemy.position);
    
    // D. Está no raio de busca?
    if (distSq > searchRadiusSq) continue;

    // --- REGRAS DE PRIORIDADE ---
    
    // E. Checagem de TAUNT (Provocação)
    // Se o inimigo tem status TAUNT, ele sobrescreve a distância (se estiver no range)
    if (enemy.hasStatus(Status.TAUNT)) {
        // Se já tínhamos um alvo com Taunt mais perto, mantemos o mais perto.
        // Se o alvo anterior não tinha Taunt, este ganha imediatamente.
        if (bestTarget == null || !bestTarget.hasStatus(Status.TAUNT) || distSq < minDistanceSq) {
            bestTarget = enemy;
            minDistanceSq = distSq;
        }
        continue; // Pula lógica normal de distância se achou um Taunt
    }
    
    // Se já achamos um Taunt antes, ignoramos não-taunts
    if (bestTarget != null && bestTarget.hasStatus(Status.TAUNT)) continue;

    // F. Lógica Padrão: Mais Próximo
    if (distSq < minDistanceSq) {
      // Desempate Opcional: Menor HP (Execute) ou Maior Ameaça
      bestTarget = enemy;
      minDistanceSq = distSq;
    }
  }
  
  return bestTarget;
}
```

---

## 4. Regras de Retargeting (Reavaliação)

Uma unidade **NÃO** troca de alvo a cada tick para evitar comportamento errático (jitter). Ela mantém o alvo ("Lock-on") até que uma condição de quebra ocorra.

### Condições de Quebra de Alvo (Target Lost)
A unidade volta para o estado `SEARCHING` se:
1.  **Morte:** O alvo atual morre (`hp <= 0`).
2.  **Alcance (Leash):** O alvo sai do `AggroRange` máximo (ex: fugiu muito longe).
    *   *Nota:* Para unidades Ranged, se o alvo sai do `AttackRange` mas continua no `AggroRange`, a unidade **persegue** (MoveTo) em vez de trocar.
3.  **Estado:** A unidade atacante sofre `STUN`, `FREEZE` ou `FEAR`. Ao recuperar, ela reavalia o alvo mais próximo (pode ser o mesmo ou outro).
4.  **Stealth:** O alvo fica invisível.
5.  **Taunt Forçado:** Uma nova unidade inimiga usa uma habilidade ativa de "Call to Arms" ou "Taunt" global/área.

### Comportamento de Torres (Especial)
Torres são "teimosas".
*   Elas travam no **primeiro** inimigo que entrar no alcance.
*   Só trocam se esse inimigo morrer ou sair do alcance.
*   **Não trocam** se um inimigo mais próximo aparecer depois (a menos que seja uma unidade com Taunt ou mecânica de "Zap" que reseta a torre).

---

## 5. Construções e "Kiting" (Atração)

Construções defensivas (Canhões, Teslas) possuem um atributo oculto: **Hitbox de Atração**.
*   Unidades com `TargetMask: BUILDING_ONLY` (Gigantes) "enxergam" construções de muito longe (Aggro Range infinito ou muito grande para Buildings).
*   Isso permite a tática de colocar um canhão no meio da arena para desviar um Gigante que estava indo para a Torre da Princesa.
*   **Regra:** Se uma construção é colocada, o `TargetingSystem` força uma reavaliação imediata de todas as unidades `SIEGE` inimigas para ver se a nova construção é mais próxima que a Torre atual.

---

## 6. Dados para Tuning

| Parâmetro | Descrição | Valor Típico |
| :--- | :--- | :--- |
| `AttackRange` | Distância máxima para iniciar ataque. | Melee: 1.0, Ranged: 5.0+ |
| `AggroRange` | Distância para "notar" inimigos e começar a andar até eles. | Geral: 6.0 a 8.0 |
| `SightRadius` | (Opcional) Visão total para renderização/fog of war. | 10.0 |
| `RetargetDelay` | Tempo entre checagens de novos alvos (otimização). | 0.1s a 0.5s |
