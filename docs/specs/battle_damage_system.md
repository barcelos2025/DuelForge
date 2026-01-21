# Especificação do Sistema de Dano e Efeitos

**Contexto:** DuelForge (Combate Tático)  
**Responsabilidade:** Calcular dano final, aplicar efeitos de status e gerenciar projéteis.

---

## 1. Fórmula de Dano

O cálculo de dano deve ser determinístico e de fácil balanceamento.

```dart
double calculateFinalDamage(Unit attacker, Unit target, double baseDamage, DamageType type) {
  // 1. Multiplicadores de Ataque (Buffs, Rage, Level Disparity)
  double attackMultiplier = attacker.getStat(Stat.DAMAGE_MULTIPLIER); // Base 1.0
  
  // 2. Mitigação de Defesa (Escudos, Resistências)
  // Em DuelForge, não usamos Armor Flat para evitar matemática complexa. 
  // Usamos % de Redução.
  double damageReduction = target.getStat(Stat.DAMAGE_REDUCTION); // Base 0.0 (0%)
  
  // Regra: Redução máxima de 80% para evitar imortalidade.
  damageReduction = damageReduction.clamp(0.0, 0.8);

  // 3. Cálculo
  double finalDamage = baseDamage * attackMultiplier * (1.0 - damageReduction);
  
  // 4. Arredondamento (Opcional, para UI limpa)
  return finalDamage.ceilToDouble();
}
```

---

## 2. Tipos de Dano e Elementos

| Tipo | Cor Visual | Comportamento Padrão |
| :--- | :--- | :--- |
| **FÍSICO** | Branco/Amarelo | Dano padrão. Bloqueável por escudos físicos. |
| **MÁGICO (Rúnico)** | Roxo/Azul | Dano padrão. Ignora certas resistências físicas (se houver). |
| **GELO (Frost)** | Ciano | Aplica efeito **SLOW** ou **FREEZE**. |
| **VENENO (Poison)** | Verde | Aplica efeito **POISON** (DoT). Ignora escudos temporários (dano direto na vida). |
| **ELÉTRICO (Shock)** | Amarelo Raio | Pode causar **MICRO-STUN** (0.5s) ou **CHAIN** (pula para próximo alvo). |

---

## 3. Sistema de Status (Buffs/Debuffs)

Os efeitos são processados no `StatusSystem` a cada tick.

### Regras de Aplicação e Stacking

#### A. POISON (Veneno)
*   **Tipo:** Damage over Time (DoT).
*   **Mecânica:** Causa X dano a cada Y segundos (Tick Rate: 1s).
*   **Stacking:** **Renovação**. Se aplicar novo veneno, reseta a duração. Não aumenta o dano por tick (para evitar burst excessivo), a menos que seja uma carta específica "Stacking Poison".
*   **Exemplo:** Dano 20/s por 5s. Total 100.

#### B. SLOW / FREEZE (Gelo)
*   **Tipo:** Modificador de Atributo (Speed, AttackSpeed).
*   **Mecânica:** Reduz velocidade de movimento e ataque em %.
*   **Stacking:** **Maior Intensidade Prevalece**.
    *   Ex: Unidade com Slow 30% recebe Slow 50%. Efeito passa a ser 50%.
    *   Ex: Unidade com Slow 50% recebe Slow 30%. Mantém 50% até acabar, depois cai para 30% (se durar mais) ou zero.
*   **Freeze Total:** É um Stun visualmente diferente. Para tudo.

#### C. STUN / SHOCK (Atordoamento)
*   **Tipo:** Controle de Grupo (Hard CC).
*   **Mecânica:** Impede movimento e ataque. Reseta o ciclo de ataque (wind-up).
*   **Stacking:** **Renovação de Duração**. O tempo restante é sobrescrito pelo novo, se o novo for maior.
*   **Micro-Stun:** Duração muito curta (0.1s) usada para interromper ataques carregados (Reset Attack Timer).

#### D. RAGE (Fúria)
*   **Tipo:** Buff.
*   **Mecânica:** Aumenta MoveSpeed e AttackSpeed (+40%).
*   **Stacking:** Não stacka. Renova duração.

---

## 4. Projéteis e Área de Efeito (AOE)

### Projéteis (Projectiles)
Entidades temporárias gerenciadas pelo `ProjectileSystem`.

1.  **Homing (Teleguiado):**
    *   Alvo: `UnitID`.
    *   Comportamento: Atualiza vetor de direção a cada tick mirando na posição atual do alvo.
    *   Hit: Garantido, a menos que alvo morra/fique invulnerável antes do impacto.
    *   Uso: Flechas, Magias básicas.
2.  **Skillshot / Linear:**
    *   Alvo: `Vector2` (Posição fixa).
    *   Comportamento: Viaja em linha reta até o destino.
    *   Hit: Checa colisão com qualquer unidade inimiga no caminho (se perfurante) ou explode no destino.
    *   Uso: Bola de Fogo, Tronco.

### Área de Efeito (AOE)
*   **Forma:** Círculo (Raio R).
*   **Dano:** **Uniforme**. Todo mundo dentro do raio toma o mesmo dano. (Simplificação para clareza competitiva).
*   **Friendly Fire:** Desativado por padrão. Atinge apenas inimigos.

---

## 5. Prevenção de Bugs Comuns

1.  **Double Hit (Dano Duplo no mesmo frame):**
    *   *Solução:* Projéteis de área ou perfurantes devem manter uma lista `Set<String> hitEntities`. Ao colidir, verifica se ID já está na lista. Se sim, ignora.
2.  **Infinite Stacking:**
    *   *Solução:* Usar regras de "Renovação" ou "Maior Intensidade" em vez de soma aritmética cega.
3.  **Desync de Morte:**
    *   *Problema:* Unidade morre no tick X, mas projétil que a matou continua existindo e explode visualmente no tick X+1.
    *   *Solução:* Se o alvo de um projétil Homing morrer, o projétil deve ou desaparecer imediatamente ou cair no chão inofensivamente (fizzling).
4.  **Ghost Damage:**
    *   *Problema:* Unidade ataca no momento exato que morre.
    *   *Solução:* Validar `attacker.isAlive` no momento da aplicação do dano, não apenas no início da animação de ataque.

---

## 6. Parâmetros de Tuning (Exemplo JSON)

```json
{
  "effects": {
    "poison_standard": {
      "duration": 5.0,
      "tick_interval": 1.0,
      "damage_per_tick": 20,
      "type": "POISON"
    },
    "ice_wizard_slow": {
      "duration": 2.0,
      "speed_reduction": 0.35,
      "attack_speed_reduction": 0.35,
      "type": "SLOW"
    },
    "zap_stun": {
      "duration": 0.5,
      "type": "STUN"
    }
  }
}
```
