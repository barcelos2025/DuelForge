# Especificação de Lógica de Cartas em Batalha

**Contexto:** DuelForge (Flutter + Flame)  
**Responsabilidade:** Gerenciamento de Mão, Ciclo de Deck e Interação de Deploy (Drag & Drop).

---

## 1. Ciclo de Cartas (Deck Rotation)

O sistema gerencia um baralho de 8 cartas, mantendo 4 na mão ativa e uma fila de "próximas".

### Estrutura de Dados
```dart
class BattleDeckState {
  final List<String> fullDeckIds; // As 8 cartas do loadout
  
  List<String?> hand; // 4 Slots (pode ter null durante animação de compra)
  Queue<String> drawPile; // Fila de compra
  String? nextCard; // A carta que aparece no slot "Next" (preview)
  
  // Controle de Elixir
  double currentElixir;
}
```

### Fluxo de Jogo (Play Cycle)
1.  **Estado Inicial:** `hand` preenchida com 4 cartas aleatórias do deck. `drawPile` contém as outras 4. `nextCard` é o topo do `drawPile`.
2.  **Ação de Jogar (Cast):**
    *   Jogador arrasta e solta carta do `hand[i]` em local válido.
    *   **Consumo:** `currentElixir -= cardCost`.
    *   **Remoção:** `hand[i]` torna-se `null` (ou estado "consumido").
    *   **Reciclagem:** A carta jogada vai para o final da `drawPile`.
3.  **Reposição (Draw):**
    *   Imediatamente (ou após delay de 0.5s), `hand[i]` recebe `nextCard`.
    *   `nextCard` é atualizado com o novo topo da `drawPile`.
    *   Inicia-se o "Cooldown de Deploy" (ex: 1s) onde a nova carta aparece visualmente mas não pode ser usada.

---

## 2. Máquina de Estados da Carta (Interaction State Machine)

Cada carta na mão possui um estado que dita sua aparência e interatividade.

| Estado | Descrição | Visual | Lógica |
| :--- | :--- | :--- | :--- |
| **LOCKED** | Elixir insuficiente. | Grayscale, Opacidade 0.7, Ícone de Gota pulsando vermelho se tentar tocar. | `onDragStart` bloqueado. Tocar toca SFX "Error". |
| **READY** | Elixir suficiente. | Cor normal, Glow sutil, Borda destacada. | `onDragStart` permitido. |
| **DRAGGING** | Sendo arrastada pelo dedo. | Carta fica menor/ícone segue o dedo. "Ghost" aparece no mapa. | Atualiza posição do Ghost. Verifica zona válida. |
| **CASTING** | Solta em local válido. | Animação de "voar" para o mapa e desaparecer da mão. | Envia comando para Simulação. Inicia ciclo de reposição. |
| **RETURNING** | Solta em local inválido ou cancelada. | Animação rápida de volta para o slot da mão. | Retorna ao estado READY ou LOCKED. |

---

## 3. Lógica de Deploy e Validação

A validação ocorre em tempo real durante o estado `DRAGGING`.

### Regras de Zona (Zone Validation)
*   **Unidades (Ground/Air):**
    *   `Valid`: Y > `RiverLine` (Lado do Jogador).
    *   `Invalid`: Y <= `RiverLine` (Lado Inimigo) OU Sobrepondo Rio (se terrestre).
    *   *Exceção:* Se uma torre inimiga caiu, a zona válida expande (Pocket Deploy).
*   **Construções:**
    *   `Valid`: Lado do Jogador E Sem colisão com outras construções/torres.
    *   `Invalid`: Sobrepondo outra estrutura.
*   **Feitiços:**
    *   `Valid`: Todo o mapa (Global).
    *   *Opcional:* Alguns feitiços podem ter alcance limitado ao redor de unidades aliadas (ex: Heal).

### Validação de Recursos e Limites
1.  **Checagem de Custo:** `PlayerElixir >= CardCost`. (Feita antes do drag).
2.  **Limite de Construções:**
    *   Se `CardType == Building`: Verificar `activeBuildingsCount`.
    *   Se `activeBuildingsCount >= MAX_BUILDINGS (2)`:
        *   Retornar `Invalid`.
        *   Feedback: Texto flutuante "Limite de Construções!".

---

## 4. UX e Feedback Visual

### Ghost Preview (O Fantasma)
Ao arrastar a carta, uma projeção da unidade aparece no campo seguindo o dedo (snapped ao grid se necessário).
*   **Material:** Shader semi-transparente.
*   **Cores de Estado:**
    *   **Verde/Azul:** Posição Válida.
    *   **Vermelho:** Posição Inválida (zona inimiga, sobreposição).
*   **Indicadores:**
    *   **Range Circle:** Se a unidade tem alcance (Arqueira, Torre), mostrar círculo branco de raio.
    *   **Area of Effect (AoE):** Se for Feitiço (Bola de Fogo), mostrar círculo de impacto no chão.

### Highlight de Zona
Ao iniciar o drag (`onDragStart`):
*   Iluminar a área permitida de deploy no chão da arena (ex: grid azulado sutil).
*   Escurecer levemente a área proibida.

### Confirmação (The "Plop")
Ao soltar em local válido (`onDragEnd`):
1.  A carta na UI some.
2.  Um efeito de partícula/fumaça ocorre no local do spawn.
3.  O servidor/simulação processa o spawn (delay de 1s de "deploy time" da unidade é comum para dar tempo de reação ao oponente).

---

## 5. Dados para UI (ViewModel)

O componente visual da mão (`HandWidget` ou `FlameHandComponent`) precisa observar estes dados:

```dart
class CardUIModel {
  final String instanceId; // ID único para esta instância na mão
  final String cardId; // ID do tipo (ex: "archer_01")
  final int elixirCost;
  final CardType type; // Unit, Building, Spell
  
  // Estado Dinâmico
  bool isPlayable; // (elixir >= cost)
  bool isNew; // Para animação de entrada na mão
  double cooldownRatio; // Se houver cooldown global
}

class DragContext {
  final CardUIModel card;
  final Vector2 currentTouchPosition;
  final bool isValidPosition;
  final String? invalidReason; // "Zona Inimiga", "Sem Elixir", "Limite Atingido"
}
```
