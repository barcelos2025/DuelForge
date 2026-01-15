# DuelForge UI Assets - Technical Production Guide

## 🎯 Objetivo

Criar um pacote completo de UI otimizado para mobile com:
- **9-slice panels** para escalabilidade sem distorção
- **Sprite sheets** para animações otimizadas
- **Atlas textures** para performance
- **Multi-resolution** (1x e 2x) para diferentes densidades de tela

---

## 📐 Especificações Técnicas

### Resolução e Padding
- **Ícones**: 96x96 (2x) + 48x48 (1x)
- **Itens**: 512x512 (2x) + 256x256 (1x)
- **Baús**: 512x512
- **Sprite Sheets**: 256x256 ou 512x512 por frame
- **Padding**: 8% ao redor do item para evitar corte

### 9-Slice Components
Cada painel 9-slice precisa de 3 assets:
1. **Corner** (cantos isolados)
2. **Edge** (bordas isoladas)
3. **Center** (miolo repetível)

### Sprite Sheet Layout
- Frames organizados em grid horizontal ou matricial
- Margem entre frames para evitar bleeding
- Transparência total no fundo

---

## 🎨 Prompts de Geração (Prontos para Uso)

### A) 9-SLICE PANELS

#### 1. Panel Base (Corner)
```
Corner piece for a 9-slice UI panel, Nordic fantasy mobile game, premium 3D cartoon style. Frosted glass effect with brushed metal border, subtle carved runes, cyan magical glow accent. Top-left corner only, 128x128px, transparent background, clean edges, cinematic lighting, game-ready asset, no text.
```

#### 2. Panel Base (Edge)
```
Edge piece for a 9-slice UI panel, Nordic fantasy mobile game, premium 3D cartoon style. Frosted glass effect with brushed metal border, subtle carved runes, cyan magical glow accent. Horizontal edge only, tileable, 128x32px, transparent background, clean edges, cinematic lighting, game-ready asset, no text.
```

#### 3. Panel Base (Center)
```
Center tile for a 9-slice UI panel, Nordic fantasy mobile game, premium 3D cartoon style. Frosted glass effect with subtle texture, very faint runes. Fully tileable, 64x64px, transparent background, seamless pattern, cinematic lighting, game-ready asset, no text.
```

#### 4-6. Panel Card (Corner/Edge/Center)
```
[Same as Panel Base but add:] Designed for card slots, slightly darker, more defined border, card-shaped aesthetic.
```

#### 7-9. Tooltip (Corner/Edge/Center)
```
[Same as Panel Base but add:] Lightweight tooltip style, thinner border, small speech bubble tail on bottom-left corner (corner piece only).
```

### B) PROGRESS BARS (9-Slice)

#### 10. Progress Bar Base
```
Base container for a progress bar, Nordic fantasy mobile game, premium 3D cartoon style. Dark metal frame with carved runes, empty state, 9-slice ready with corners and edges, 256x32px, transparent background, cinematic lighting, game-ready asset, no text.
```

#### 11. Progress Bar Fill
```
Fill element for a progress bar, Nordic fantasy mobile game, premium 3D cartoon style. Glowing cyan energy with flowing runes, animated appearance, 9-slice ready, 256x32px, transparent background, cinematic lighting, game-ready asset, no text.
```

#### 12-13. Rune Bar (Base + Fill)
```
[Same as Progress Bar but add:] Specifically for rune energy, more magical appearance, floating rune particles, cyan to golden gradient fill.
```

### C) BUTTONS (Multiple States)

#### 14. Button Primary Small Normal
```
Small primary button for mobile game UI, Nordic fantasy style, premium 3D cartoon. Cyan runic glow, brushed metal with carved runes, rounded rectangle, normal state, 128x48px, transparent background, cinematic lighting, subtle outline, game-ready asset, no text.
```

#### 15. Button Primary Small Pressed
```
[Same as #14 but add:] Pressed state, slightly darker, compressed appearance, stronger inner glow, pressed down effect.
```

#### 16. Button Primary Small Disabled
```
[Same as #14 but add:] Disabled state, desaturated, faded runes, no glow, grayed out appearance.
```

#### 17-18. Button Primary Medium/Large
```
[Same as #14 but change size to:] 192x56px (Medium), 256x64px (Large)
```

#### 19. Button CTA Battle Normal
```
Giant CTA button for "Battle" action, Nordic fantasy mobile game, premium 3D cartoon. Golden gradient with intense glow, layered depth, pulsating runic aura, epic appearance, normal state, 320x96px, transparent background, cinematic lighting, game-ready asset, no text.
```

#### 20. Button CTA Battle Pressed
```
[Same as #19 but add:] Pressed state, compressed, stronger glow burst, energy release effect.
```

#### 21. Button Icon Circle Normal
```
Circular icon button for mobile game UI, Nordic fantasy style, premium 3D cartoon. Brushed metal circle with subtle rune border, normal state, 64x64px, transparent background, cinematic lighting, game-ready asset, no icon inside (empty).
```

### D) CHESTS (Static + Animations)

#### 22. Chest Common Closed
```
Common wooden chest for mobile game, Nordic fantasy style, premium 3D cartoon. Simple wood with iron bands, small carved runes, closed state, isometric 3/4 view, 512x512px, transparent background, cinematic lighting, game-ready asset, no text.
```

#### 23. Chest Common Ready
```
[Same as #22 but add:] Ready to open state, glowing green aura, pulsating light from cracks, magical particles floating around.
```

#### 24. Chest Common Opening
```
[Same as #22 but add:] Mid-opening state, lid slightly open, bright light bursting out, energy rays, magical explosion starting.
```

#### 25-27. Chest Legendary (Closed/Ready/Opening)
```
[Same as #22-24 but change:] Legendary quality, ornate golden chest with intricate carvings, glowing runes, golden magical aura, epic appearance.
```

#### 28-30. Chest Master/Arena
```
[Similar structure, adjust for Master (ruby/red theme) and Arena (Viking ship/rope theme)]
```

### E) SPRITE SHEET ANIMATIONS

#### 31. Chest Opening Loop (12 frames)
```
Sprite sheet animation for chest opening loop, 12 frames, Nordic fantasy mobile game. Chest vibrating and glowing with increasing intensity, runic particles floating, 256x256px per frame, arranged in 4x3 grid, 1024x768px total, transparent background, cinematic lighting, game-ready asset.
```

#### 32. Chest Burst Reward (16 frames)
```
Sprite sheet animation for chest reward burst, 16 frames, Nordic fantasy mobile game. Explosive light burst with magical particles, runes flying outward, energy waves, 512x512px per frame, arranged in 4x4 grid, 2048x2048px total, transparent background, cinematic lighting, game-ready asset.
```

#### 33. Select Glow Loop (12 frames)
```
Sprite sheet animation for item selection glow, 12 frames loop, Nordic fantasy mobile game. Circular cyan runic glow pulsating smoothly, rotating runes, 128x128px per frame, arranged in 4x3 grid, 512x384px total, transparent background, game-ready asset.
```

#### 34. Press Feedback (8 frames)
```
Sprite sheet animation for button press feedback, 8 frames, Nordic fantasy mobile game. Quick cyan energy ripple expanding outward, 128x128px per frame, arranged in 4x2 grid, 512x256px total, transparent background, game-ready asset.
```

#### 35. CTA Rune Pulse (16 frames)
```
Sprite sheet animation for CTA button rune pulse, 16 frames loop, Nordic fantasy mobile game. Runic symbols glowing and fading in sequence, magical energy flow, 256x256px per frame, arranged in 4x4 grid, 1024x1024px total, transparent background, game-ready asset.
```

#### 36. Lightning Sparks (12 frames)
```
Sprite sheet animation for lightning VFX, 12 frames, Nordic fantasy mobile game. Electric cyan sparks and bolts, crackling energy, 256x256px per frame, arranged in 4x3 grid, 1024x768px total, transparent background, game-ready asset.
```

#### 37. Frost Shards (12 frames)
```
Sprite sheet animation for frost VFX, 12 frames, Nordic fantasy mobile game. Ice shards forming and shattering, blue crystalline particles, 256x256px per frame, arranged in 4x3 grid, 1024x768px total, transparent background, game-ready asset.
```

#### 38. Poison Smoke Loop (16 frames)
```
Sprite sheet animation for poison VFX, 16 frames loop, Nordic fantasy mobile game. Emerald green toxic smoke swirling, bubbling particles, 256x256px per frame, arranged in 4x4 grid, 1024x1024px total, transparent background, game-ready asset.
```

#### 39. Level Up Burst (16 frames)
```
Sprite sheet animation for level up effect, 16 frames, Nordic fantasy mobile game. Golden energy explosion with ascending runes, star particles, triumphant burst, 512x512px per frame, arranged in 4x4 grid, 2048x2048px total, transparent background, game-ready asset.
```

---

## 📦 Atlas Organization

### Atlas UI (Ícones, Botões, Badges)
- Ícones de navegação (48x48 e 96x96)
- Botões (todos os tamanhos e estados)
- Badges de raridade
- Elementos de UI pequenos

### Atlas Items (Consumíveis, Recursos)
- Moedas, cristais, gemas
- Poções
- Fragmentos de carta
- Itens de upgrade

### Atlas VFX (Animações)
- Todos os sprite sheets
- Efeitos de partículas
- Overlays de UI

---

## 🔧 Workflow de Produção

### Fase 1: Geração de Assets (Quando quota resetar)
1. Gerar 9-slice panels (9 assets)
2. Gerar progress bars (4 assets)
3. Gerar botões (8+ assets)
4. Gerar baús estáticos (6+ assets)
5. Gerar sprite sheets (9 assets)

### Fase 2: Processamento
1. Verificar transparência e bordas
2. Validar dimensões e padding
3. Organizar em pastas corretas

### Fase 3: Integração
1. Copiar para `assets/ui/`
2. Atualizar `pubspec.yaml`
3. Atualizar `df_assets_technical.dart`
4. Criar atlas JSON metadata

### Fase 4: Testes
1. Testar 9-slice em diferentes tamanhos
2. Testar animações em diferentes FPS
3. Validar performance com atlas

---

## ⏰ Status Atual

**Quota de Geração**: Reset em ~4h30min  
**Assets Prontos**: 21/100 (básicos já integrados)  
**Próxima Geração**: ~40 assets técnicos (9-slice, botões, sprite sheets)  

**Infraestrutura Pronta**:
- ✅ Estrutura de pastas
- ✅ Classes de assets
- ✅ Widgets técnicos (9-slice, sprite sheet)
- ✅ Prompts de geração
- ✅ Documentação completa

---

**Última atualização**: 14/01/2026 00:30  
**Versão**: v0.2-technical  
**Autor**: AI Director de Arte AAA
