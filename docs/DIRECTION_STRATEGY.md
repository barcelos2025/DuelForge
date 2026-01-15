# Estratégia de Direções e Renderização - DuelForge

Este documento define a lógica para lidar com direções de sprites, garantindo suporte tanto para o MVP (2 direções) quanto para a versão final "AAA" (8 direções).

## 1. Definição dos Modos

### Modo MVP (2 Direções + Flip)
Focado em economizar memória e tempo de renderização inicial.
*   **Arquivos Gerados**:
    *   `_up.png` (Representa "Costas" ou "Indo para Longe"). Renderizado como **Norte-Leste (NE)** ou **Norte (N)**.
    *   `_down.png` (Representa "Frente" ou "Vindo para Perto"). Renderizado como **Sul-Leste (SE)** ou **Sul (S)**.
*   **Cobertura**:
    *   Movimentos para o "Fundo" (N, NE, NW) usam `_up`.
    *   Movimentos para a "Frente" (S, SE, SW) usam `_down`.
    *   Movimentos laterais puros (E, W) decidem baseados na última direção vertical ou usam `_down` por padrão (mostra o rosto).

### Modo AAA (8 Direções)
Focado em qualidade visual máxima (sem "pulo" de iluminação, sem virar canhoto).
*   **Arquivos Gerados**: `_n`, `_ne`, `_e`, `_se`, `_s`, `_sw`, `_w`, `_nw`.
*   **Cobertura**: Cada arquivo cobre um arco de 45° em volta da sua direção.

---

## 2. Lógica de Seleção (Runtime)

O sistema deve calcular o vetor de velocidade ou vetor para o alvo `(dx, dy)`.

### Passo 1: Calcular Ângulo
```dart
double angle = atan2(dy, dx); // Retorna radianos entre -PI e PI
// Converter para graus (0 a 360) para facilitar
double degrees = (angle * 180 / PI);
if (degrees < 0) degrees += 360;
```
*   `0°` = Direita (Leste)
*   `90°` = Baixo (Sul) - *No sistema de coordenadas de tela do Flutter*
*   `270°` = Cima (Norte)

### Passo 2: Mapear para Sufixo de Arquivo

#### Lógica para 8 Direções (AAA)
Dividir o círculo em 8 fatias de 45° (22.5° para cada lado do eixo).
*   `337.5°` a `22.5°` -> **E**
*   `22.5°` a `67.5°` -> **SE**
*   `67.5°` a `112.5°` -> **S**
*   `112.5°` a `157.5°` -> **SW**
*   `157.5°` a `202.5°` -> **W**
*   `202.5°` a `247.5°` -> **NW**
*   `247.5°` a `292.5°` -> **N**
*   `292.5°` a `337.5°` -> **NE**

#### Lógica para 2 Direções (MVP)
Simplificar baseando-se apenas no eixo Y (Vertical).
*   Se `dy < 0` (Indo para cima/Norte) -> **UP**
*   Se `dy >= 0` (Indo para baixo/Sul) -> **DOWN**

### Passo 3: Flip Horizontal (Espelhamento)
Apenas necessário se não tivermos as direções da esquerda (W, NW, SW) renderizadas nativamente.

*   **Regra**: Se `dx < 0` (Indo para a esquerda) -> **Flip = TRUE**.
*   **No Modo MVP**:
    *   Renderizamos o personagem olhando para a **Direita** (NE para `_up`, SE para `_down`).
    *   Se ele for para a esquerda, espelhamos.

---

## 3. Solução para "Flip Feio" (Iluminação e Assimetria)

O problema: Ao espelhar um sprite renderizado com luz vindo da esquerda, a luz passa a vir da direita no sprite espelhado. Isso quebra a ilusão de "mundo 3D coeso".

### Solução A: Iluminação Centralizada (Recomendado para MVP)
No Blender, para os renders do modo 2 Direções:
*   Posicione a **Key Light** (Sol) vindo diretamente de **Cima** (Top-Down) ou alinhada com a Câmera, em vez de vir do lado.
*   Isso garante que as sombras caiam principalmente para baixo.
*   Ao espelhar, a iluminação continua parecendo vir de cima.
*   *Nota*: Perde-se um pouco do volume lateral, mas ganha-se consistência no flip.

### Solução B: 5 Direções (Meio Termo)
Renderizar `N, NE, E, SE, S`.
*   Espelhar `NE` para criar `NW`.
*   Espelhar `SE` para criar `SW`.
*   Espelhar `E` para criar `W`.
*   Isso resolve o problema de ver as costas vs frente incorretamente, mas ainda sofre com a luz se ela for muito lateral.

### Solução C: Simetria de Design
*   Evite personagens muito assimétricos no MVP (ex: ombreira gigante só de um lado).
*   Se o personagem for destro (espada na direita), ao espelhar ele vira canhoto. Isso é aceitável em jogos estilo RTS/MOBA (Warcraft 3 e LoL faziam isso em unidades menores), mas deve ser evitado em Heróis principais se possível.

## 4. Padrão de Arquivos e Loader Inteligente

O `AssetLoader` deve ser capaz de detectar o que está disponível na pasta e se adaptar.

**Estrutura de Arquivos**:
```
units/
  shield_warrior/
    walk_down.png  (Renderizado como SE)
    walk_up.png    (Renderizado como NE)
```

**Algoritmo do Loader**:
1.  Tenta carregar `walk_se.png`, `walk_n.png`, etc. (Modo 8 dirs).
2.  Se falhar, tenta carregar `walk_down.png` e `walk_up.png` (Modo 2 dirs).
3.  Se falhar, tenta `walk.png` (Modo 1 dir - ex: construções).

**Configuração do Componente**:
O componente do jogo (`UnitComponent`) terá uma propriedade `SpriteDirectionMode`:
*   `auto`: Detecta baseado nos arquivos.
*   `fixed`: Para construções.

## Resumo da Recomendação para DuelForge Agora

1.  Use o script Blender para gerar **2 Direções** (`_up` baseada em NE, `_down` baseada em SE).
2.  No Blender, ajuste a luz para ser mais **Frontal/Superior** para esses renders específicos.
3.  No código, implemente a lógica de **Flip Horizontal** quando `dx < 0`.
4.  Isso garante o MVP visual sem criar a complexidade de gerenciar 8 texturas por animação agora.
