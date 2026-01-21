# Especificação de Arena: Odyn's Rage
**Jogo:** DuelForge  
**Estilo:** 2D Top-Down / Pseudo-Isométrico (Vertical Mobile)  
**Engine:** Flutter + Flame

---

## 1. Sistema de Coordenadas e Layout
Utilizaremos um sistema de coordenadas lógicas normalizadas para garantir consistência em diferentes resoluções de tela.
*   **World Size (Lógico):** 1000u (largura) x 1800u (altura).
*   **Origem (0,0):** Topo-Esquerda (Canto do Inimigo).
*   **Centro do Rio (Eixo Y):** 900u.

### Diagrama Textual
```text
(0,0) __________________________________________________ (1000,0)
     |                                                  |
     |        [ENEMY SPAWN ZONE (Y: 0-300)]             |
     |                                                  |
     |                 [RED KING]                       |
     |                 (500, 150)                       |
     |                                                  |
     |    [RED TOWER L]               [RED TOWER R]     |
     |    (200, 350)                  (800, 350)        |
     |                                                  |
     |         |                         |              |
     |         v      (LANE PATHS)       v              |
     |                                                  |
~~~~~|~~~~[BRIDGE L]~~~~~~[RIVER]~~~~~~[BRIDGE R]~~~~~~~|~~~~~ (Y=900)
     |    (200, 900)                  (800, 900)        |
     |                                                  |
     |         ^                         ^              |
     |         |                         |              |
     |                                                  |
     |   [BLUE TOWER L]              [BLUE TOWER R]     |
     |   (200, 1450)                 (800, 1450)        |
     |                                                  |
     |                 [BLUE KING]                      |
     |                 (500, 1650)                      |
     |                                                  |
     |        [PLAYER SPAWN ZONE (Y: 1500-1800)]        |
     |__________________________________________________|
(0,1800)
```

---

## 2. Definição de Zonas e Navegação

### Lanes (Rotas)
As unidades terrestres seguem vetores de fluxo (waypoints) baseados na lane escolhida no deploy.
*   **Lane Esquerda:** X=200. Conecta Blue Tower L <-> Bridge L <-> Red Tower L.
*   **Lane Direita:** X=800. Conecta Blue Tower R <-> Bridge R <-> Red Tower R.
*   **Desvio:** Unidades voadoras ignoram o rio e pontes, movendo-se em linha reta (Raycast).

### Zonas de Deploy (Invocação)
*   **Inicial:** Todo o campo aliado atrás do rio (Y > 950 para Blue, Y < 850 para Red).
*   **Expansão:** Se uma Torre Lateral inimiga for destruída, a zona de deploy avança para o lado inimigo naquela lane, permitindo "Pocket Deploy".
*   **Restrição:** Não é possível invocar sobre estruturas ou no rio (exceto unidades aquáticas/voadoras específicas, se houver).

### Colisões
*   **Hard Collision:** Estruturas (Torres) e Bordas do Mapa. Unidades devem contornar (Steering Behavior: Obstacle Avoidance).
*   **Soft Collision:** Outras unidades. Unidades aliadas se empurram levemente (Separation). Unidades inimigas bloqueiam caminho se forem terrestres (Body Block).

---

## 3. Estruturas e Atributos (Tuning Base)

### Torre da Princesa (Torres Laterais)
Defesa primária rápida e com alcance médio.
*   **HP:** 1400
*   **Dano:** 90
*   **Cadência (RoF):** 0.8s (Rápida)
*   **Alcance:** 7.5 tiles (750u lógicas se 1 tile = 100u, ou ajustar escala visual)
*   **Tipo de Ataque:** Projétil Único (Flecha/Runa). Dano Físico.
*   **Alvo:** Terrestre e Aéreo.

### Torre do Rei (Coração Rúnico - Central)
Defesa final. Inicialmente "adormecida" até ser atingida ou uma torre lateral cair.
*   **HP:** 2400
*   **Dano:** 110
*   **Cadência (RoF):** 1.0s
*   **Alcance:** 8.0 tiles
*   **Tipo de Ataque:** Projétil Mágico (Canhão Rúnico). Dano em Área pequeno (Splash 1.0u).
*   **Estado Especial:** "Ativação". Só ataca se sofrer dano ou se uma Torre da Princesa for destruída.

---

## 4. Regras de Combate e Targeting

### Prioridade de Alvo (Targeting Logic)
As torres e unidades seguem esta hierarquia a cada tick de decisão (0.1s):
1.  **Distância:** Inimigo mais próximo dentro do alcance (`distanceTo(target) <= range`).
2.  **Aggro (Provocação):** Se uma unidade ataca a torre, ela tende a focar nessa unidade (opcional, para mecânicas de "Tank").
3.  **Persistência:** Uma vez travado num alvo, a torre continua atacando até que:
    *   O alvo morra.
    *   O alvo saia do alcance.
    *   A torre seja atordoada (Zap/Freeze).

### Regras de Vitória
1.  **Destruição do Rei:** Se o HP do Coração Rúnico chegar a 0 -> **Vitória Imediata** (3 Coroas).
2.  **Tempo Limite (3:00):**
    *   Quem tiver mais torres destruídas vence.
    *   Se igual, vence quem causou mais dano total às torres remanescentes (Desempate por HP).
    *   Se tudo igual -> **Overtime**.

### Overtime (Morte Súbita)
*   **Duração:** +60 segundos (Standard) ou +180s (Ranked).
*   **Regra:** A primeira torre a ser destruída encerra o jogo instantaneamente.
*   **Recursos:** Geração de Elixir (Mana) acelerada (2x ou 3x) para forçar o fim.
*   **Empate:** Se o tempo acabar e ninguém destruir nada, o jogo termina em **Empate**.

---

## 5. Parâmetros para Implementação (Flame Components)

### Classes Sugeridas
*   `ArenaStructure extends PositionComponent`: Base para torres.
*   `PrincessTower extends ArenaStructure`: Lógica específica de tiro rápido.
*   `KingTower extends ArenaStructure`: Lógica de ativação.
*   `UnitComponent extends PositionComponent`: Com `MoveToEffect` ou `SteeringBehavior`.
*   `ProjectileComponent`: `MoveToEffect` com callback `onFinish` para causar dano.

### Constantes de Tuning (Dart)
```dart
class ArenaConfig {
  // Dimensões
  static const double width = 1000.0;
  static const double height = 1800.0;
  static const double riverY = 900.0;
  
  // Posições (Blue Side)
  static final Vector2 blueKingPos = Vector2(500, 1650);
  static final Vector2 blueTowerLPos = Vector2(200, 1450);
  static final Vector2 blueTowerRPos = Vector2(800, 1450);
  
  // Posições (Red Side)
  static final Vector2 redKingPos = Vector2(500, 150);
  static final Vector2 redTowerLPos = Vector2(200, 350); // Espelhado visualmente
  static final Vector2 redTowerRPos = Vector2(800, 350);

  // Atributos
  static const double towerRange = 250.0; // Exemplo em pixels
  static const double kingRange = 300.0;
  static const double aggroRange = 400.0;
}
```
