# Padrão de Assets "3D Fake AAA" - DuelForge

Este documento define os padrões oficiais para a criação, exportação e integração de assets pré-renderizados (3D para 2D) no DuelForge.

## 1. Estrutura de Diretórios

Para compatibilidade nativa com o Flame, a raiz dos sprites é `assets/images/`.

```
assets/
  images/
    units/
      <unit_id>/
        <anim>_<dir>.png      (Ex: shield_warrior_walk_se.png)
    buildings/
      <building_id>/
        <anim>.png            (Ex: catapult_idle.png)
    towers/
      <tower_id>/
        <anim>.png            (Ex: king_tower_idle.png)
    vfx/
      <vfx_id>/
        <anim>.png            (Ex: lightning_cloud_cast.png)
    ui/
      ...
```

## 2. Convenção de Nomes

### Identificadores (IDs)
- **Formato**: `snake_case` (minúsculas, separadas por underscore).
- **Restrição**: Sem acentos ou caracteres especiais.
- **Exemplos**: `shield_warrior`, `king_tower`, `lightning_cloud`.

### Animações (`anim`)
Padronizadas para garantir consistência no código:
- `idle` (Parado/Respirando)
- `walk` (Movimento)
- `attack` (Ação ofensiva principal)
- `hit` (Recebendo dano)
- `death` (Morrendo/Desaparecendo)
- `cast` (Lançando habilidade/spell - opcional)
- `spawn` (Aparecendo/Invocação - opcional)
- `destroy` (Para construções destruídas)

### Direções (`dir`)
Para manter o visual "AAA", recomenda-se o uso de **8 direções** para unidades móveis.
- **Códigos**: `n`, `ne`, `e`, `se`, `s`, `sw`, `w`, `nw`.
- **Simplificação (Opcional)**: Se 8 for inviável para certas unidades, usar `up` (N/NE/NW) e `down` (S/SE/SW).
- **Construções**: Geralmente possuem direção fixa (ex: `idle` apenas), ou `se` se houver rotação fixa.

## 3. Padrões Técnicos

### Formato de Arquivo
- **Tipo**: Spritesheets (Grid) ou Sequência de PNGs (preferência por Spritesheets para performance no Flame).
- **Arquivo**: PNG 32-bit (RGB + Alpha).
- **Fundo**: Transparente.

### Resolução (Frame Size)
Tamanho do "canvas" de cada frame no spritesheet:
- **Tropas Comuns**: 256x256 px
- **Tropas Lendárias/Grandes**: 384x384 px
- **Mestre/Heróis**: 512x512 px
- **Construções**: 256x256 px ou 384x384 px (dependendo do tamanho no grid).

### Taxa de Quadros (FPS)
- **Idle / Walk**: 12 FPS (Fluidez padrão).
- **Attack / Cast**: 15 FPS (Mais impacto e agilidade).
- **Death**: 10 FPS (Dramático, levemente mais lento).

### Ancoragem (Pivot)
- **Padrão**: "Feet Pivot" (Centro inferior).
- **Motivo**: Facilita o posicionamento no tilemap isométrico e o sorting (Z-index) correto.
- **VFX**: Depende do efeito (ex: `lightning_cloud` pode ser Top Center ou Center, `poison` no chão seria Feet Pivot).

## 4. Lista de Entrega Mínima (MVP Visual)

### Tropas (4)
1.  **`shield_warrior`** (Comum, Melee, Tank)
2.  **`frost_ranger`** (Comum, Ranged, Slow)
3.  **`bear_berserker`** (Rara/Lendária, Melee, High DPS)
4.  **`thor`** (Mestre/Herói, Ranged/Melee Híbrido)

### Construções (2)
1.  **`catapult`** (Spawner/Attack Building)
2.  **`watchtower`** (Defense Building)

### Torres (1)
1.  **`king_tower`** (Torre Principal - Placeholder inicial)

### VFX (3)
1.  **`lightning_cloud`** (Área, Dano aéreo)
2.  **`poison`** (Área, Chão, Dano por tempo)
3.  **`hailstorm`** (Área, Gelo/Slow)

## 5. Checklist de Consistência Visual

Para garantir que todos os assets pareçam pertencer ao mesmo jogo ("Fake AAA"):

-   [ ] **Câmera**: Isométrica Ortográfica (True Isometric 35.264° ou Dimétrica 30°). Manter RIGOROSAMENTE a mesma angulação para todos os renders.
-   [ ] **Iluminação**:
    -   Luz Principal (Key Light): Vindo do Topo-Esquerda (padrão em UI/2D games).
    -   Luz de Preenchimento (Fill Light): Suave, azulada/fria para sombras não serem pretas absolutas.
    -   Luz de Recorte (Rim Light): Opcional, mas ajuda a destacar do fundo (efeito "premium").
-   [ ] **Escala**: Um humano padrão deve ter a mesma altura relativa em todos os arquivos antes do render.
-   [ ] **Materiais**: Estilo "Stylized PBR" (tipo Clash Royale/LoL). Evitar realismo sujo ou cartoon 2D flat.
-   [ ] **Outline**: Leve outline no render ou shader (opcional, mas ajuda na legibilidade em telas pequenas).
-   [ ] **Sombras**:
    -   **NÃO** renderizar sombras projetadas no chão (drop shadows) no sprite, pois elas "vazam" em tiles transparentes ou sobrepõem errado.
    -   Usar um componente de sombra separado no Flame (oval preta semitransparente) embaixo da unidade.
