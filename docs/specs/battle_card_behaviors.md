# Especificação de Comportamento de Cartas (Battle Logic)

**Contexto:** DuelForge  
**Objetivo:** Definir a lógica única de cada carta para implementação no `BattleEngine`.

---

## 1. Unidades (Troops)

### **Bear Berserker (Urso Guerreiro)**
*   **Tipo:** Unidade Terrestre (Melee).
*   **Spawn:** Zona Aliada.
*   **Alvo:** Ground Only.
*   **Comportamento:** Tank Ofensivo.
*   **Habilidade Passiva (Berserk):** Quando HP cai abaixo de 50% (`TUNING`), ganha status `RAGE` permanente até morrer.
    *   `RAGE`: +40% Move Speed, +40% Attack Speed.
*   **Pseudocódigo:**
    ```dart
    void onDamageTaken(double damage) {
      super.onDamageTaken(damage);
      if (hp / maxHp < 0.5 && !hasStatus(Status.RAGE)) {
        applyStatus(Status.RAGE, duration: double.infinity);
        playVFX("berserk_roar");
      }
    }
    ```

### **Frost Ranger (Patrulheira de Gelo)**
*   **Tipo:** Unidade Terrestre (Ranged).
*   **Spawn:** Zona Aliada.
*   **Alvo:** Both (Ground & Air).
*   **Comportamento:** Suporte/Controle.
*   **Ataque:** Dispara flechas de gelo.
*   **Efeito On-Hit:** Aplica `SLOW` (Gelo) por 2s (`TUNING`). Reduz Move/Atk Speed em 35%.
*   **Pseudocódigo:**
    ```dart
    void onAttackHit(Unit target) {
      target.takeDamage(damage);
      target.applyStatus(Status.SLOW, duration: 2.0, intensity: 0.35);
    }
    ```

### **Demônio Alado (Winged Demon)**
*   **Tipo:** Unidade Aérea (Melee/Short Range).
*   **Spawn:** Zona Aliada.
*   **Alvo:** Both (Ground & Air).
*   **Comportamento:** Assassino Voador.
*   **Efeito Especial (Charge):** Se estiver longe do alvo, o primeiro ataque é um "Dash" rápido que causa dano duplo (`TUNING`).
*   **Pseudocódigo:**
    ```dart
    void updateCombat() {
      if (distanceTo(target) > chargeRange && !isCharging) {
        startCharge(); // Aumenta speed x2
      }
      if (isCharging && distanceTo(target) < meleeRange) {
        target.takeDamage(damage * 2);
        stopCharge();
      }
    }
    ```

---

## 2. Construções (Buildings)

### **Catapulta (Standard)**
*   **Tipo:** Construção Defensiva/Ofensiva.
*   **Spawn:** Zona Aliada.
*   **Alvo:** Ground Only.
*   **Ataque:** Projétil em arco (Lobbed). Dano em Área (AOE).
*   **Zona Morta:** Não ataca inimigos muito próximos (Range Mínimo: 2.0u).
*   **Pseudocódigo:**
    ```dart
    void updateTargeting() {
      // Filtra inimigos muito perto
      target = findTarget(minRange: 2.0, maxRange: 11.0);
    }
    ```

### **Catapulta de Fogo (Infernal)**
*   **Tipo:** Construção Defensiva.
*   **Spawn:** Zona Aliada.
*   **Alvo:** Ground Only.
*   **Ataque:** Projétil de Magma. AOE.
*   **Efeito On-Hit:** Deixa uma poça de lava no chão por 3s OU aplica `BURN` (DoT curto) nos atingidos.
    *   *Decisão:* Aplica `BURN` por 3s.
*   **Pseudocódigo:**
    ```dart
    void onProjectileExplode(Vector2 pos, List<Unit> hitUnits) {
      for (var unit in hitUnits) {
        unit.takeDamage(damage);
        unit.applyStatus(Status.BURN, duration: 3.0);
      }
    }
    ```

---

## 3. Feitiços (Spells)

### **Nuvem de Raios (Thunder Cloud)**
*   **Tipo:** Feitiço (Instantâneo + Duração Curta).
*   **Spawn:** Global.
*   **Alvo:** Both.
*   **Efeito:** Causa dano inicial + `MICRO-STUN` (0.5s) em área.
*   **Mecânica de Chain (Opcional):** Se for complexo, manter apenas AOE simples. Se possível, raios pulam entre até 3 alvos.
    *   *Decisão MVP:* AOE Simples com Stun. "ZAP" clássico.
*   **Pseudocódigo:**
    ```dart
    void onCast(Vector2 pos) {
      var targets = getUnitsInRadius(pos, radius: 2.5);
      for (var t in targets) {
        t.takeDamage(damage);
        t.applyStatus(Status.STUN, duration: 0.5);
      }
      playVFX("lightning_strike", pos);
    }
    ```

### **Boneco Voodoo (Curse Doll)**
*   **Tipo:** Feitiço de Debuff (Área).
*   **Spawn:** Global.
*   **Alvo:** Both.
*   **Efeito:** Aplica status `CURSED` em área por 6s (`TUNING`).
*   **Status CURSED:** Unidades amaldiçoadas recebem +35% de dano de todas as fontes.
*   **Pseudocódigo:**
    ```dart
    void onCast(Vector2 pos) {
      var targets = getUnitsInRadius(pos, radius: 3.0);
      for (var t in targets) {
        t.applyStatus(Status.CURSED, duration: 6.0, amplifier: 1.35);
      }
    }
    ```

### **Veneno (Poison Cloud)**
*   **Tipo:** Feitiço DoT (Área Persistente ou Status).
*   **Spawn:** Global.
*   **Alvo:** Both (Ground & Air) e Estruturas (Dano reduzido em torres: 30%).
*   **Efeito:** Aplica status `POISON` em quem estiver na área. A área dura 4s.
*   **Pseudocódigo:**
    ```dart
    // AreaEffectEntity
    void onTick() {
      var targets = getUnitsInRadius(position, radius: 3.5);
      for (var t in targets) {
        // Renova o veneno enquanto estiver dentro
        t.applyStatus(Status.POISON, duration: 1.0); 
        // O status POISON causa o dano, não a área diretamente
      }
    }
    ```

### **Chuva de Granizo (Hailstorm)**
*   **Tipo:** Feitiço de Dano/Controle (Área).
*   **Spawn:** Global.
*   **Alvo:** Both.
*   **Efeito:** Vários projéteis caem aleatoriamente na área por 3s.
*   **On-Hit:** Dano moderado + `SLOW` forte (50%) por 1s.
*   **Pseudocódigo:**
    ```dart
    void onTick() {
      if (tick % spawnRate == 0) {
        Vector2 randomPos = getRandomPosInCircle(center, radius);
        spawnProjectile(start: skyPos, end: randomPos, onHit: (u) {
           u.takeDamage(dmg);
           u.applyStatus(Status.SLOW, duration: 1.0, intensity: 0.5);
        });
      }
    }
    ```
