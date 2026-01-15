# DuelForge UI Assets - Generation Automation Script

## 🎯 Objetivo
Este documento contém a sequência exata de comandos para gerar todos os assets técnicos assim que a quota de geração resetar.

> **Nota**: Utilize o workflow `/generate_ui_assets` para garantir que a correção de transparência seja aplicada automaticamente após cada lote.

---

## ⏰ Quando Executar
**Quota Reset**: ~4h30min (às 07:35 UTC / 04:35 BRT)

---

## 📋 Checklist Pré-Geração

- [ ] Verificar que a quota foi resetada
- [ ] Confirmar estrutura de pastas existe
- [ ] Backup dos assets existentes (opcional)
- [ ] Terminal pronto para comandos

---

## 🚀 Sequência de Geração

### LOTE 1: 9-Slice Panels (9 assets - ~15min)

```
generate_image("df_panel_base_corner_v01", "Corner piece for a 9-slice UI panel, Nordic fantasy mobile game, premium 3D cartoon style. Frosted glass effect with brushed metal border, subtle carved runes, cyan magical glow accent. Top-left corner only, 128x128px, transparent background, clean edges, cinematic lighting, game-ready asset, no text.")

generate_image("df_panel_base_edge_v01", "Edge piece for a 9-slice UI panel, Nordic fantasy mobile game, premium 3D cartoon style. Frosted glass effect with brushed metal border, subtle carved runes, cyan magical glow accent. Horizontal edge only, tileable, 128x32px, transparent background, clean edges, cinematic lighting, game-ready asset, no text.")

generate_image("df_panel_base_center_v01", "Center tile for a 9-slice UI panel, Nordic fantasy mobile game, premium 3D cartoon style. Frosted glass effect with subtle texture, very faint runes. Fully tileable, 64x64px, transparent background, seamless pattern, cinematic lighting, game-ready asset, no text.")

generate_image("df_panel_card_corner_v01", "Corner piece for a 9-slice card panel, Nordic fantasy mobile game, premium 3D cartoon style. Frosted glass effect with brushed metal border, card-shaped aesthetic, slightly darker, more defined border. Top-left corner only, 128x128px, transparent background, clean edges, cinematic lighting, game-ready asset, no text.")

generate_image("df_panel_card_edge_v01", "Edge piece for a 9-slice card panel, Nordic fantasy mobile game, premium 3D cartoon style. Frosted glass effect with brushed metal border, card-shaped aesthetic. Horizontal edge only, tileable, 128x32px, transparent background, clean edges, cinematic lighting, game-ready asset, no text.")

generate_image("df_panel_card_center_v01", "Center tile for a 9-slice card panel, Nordic fantasy mobile game, premium 3D cartoon style. Frosted glass effect, card-shaped aesthetic, subtle texture. Fully tileable, 64x64px, transparent background, seamless pattern, cinematic lighting, game-ready asset, no text.")

generate_image("df_tooltip_corner_v01", "Corner piece for a 9-slice tooltip, Nordic fantasy mobile game, premium 3D cartoon style. Lightweight frosted glass, thin border, small speech bubble tail on bottom-left. Top-left corner, 96x96px, transparent background, clean edges, cinematic lighting, game-ready asset, no text.")

generate_image("df_tooltip_edge_v01", "Edge piece for a 9-slice tooltip, Nordic fantasy mobile game, premium 3D cartoon style. Lightweight frosted glass, thin border. Horizontal edge only, tileable, 96x24px, transparent background, clean edges, cinematic lighting, game-ready asset, no text.")

generate_image("df_tooltip_center_v01", "Center tile for a 9-slice tooltip, Nordic fantasy mobile game, premium 3D cartoon style. Lightweight frosted glass, very subtle texture. Fully tileable, 48x48px, transparent background, seamless pattern, cinematic lighting, game-ready asset, no text.")
```

**Após geração**: Copiar para `assets/ui/9slice/`

---

### LOTE 2: Progress Bars (4 assets - ~7min)

```
generate_image("df_progress_base_9slice_v01", "Base container for a progress bar, Nordic fantasy mobile game, premium 3D cartoon style. Dark metal frame with carved runes, empty state, 9-slice ready with corners and edges, 256x32px, transparent background, cinematic lighting, game-ready asset, no text.")

generate_image("df_progress_fill_9slice_v01", "Fill element for a progress bar, Nordic fantasy mobile game, premium 3D cartoon style. Glowing cyan energy with flowing runes, animated appearance, 9-slice ready, 256x32px, transparent background, cinematic lighting, game-ready asset, no text.")

generate_image("df_rune_bar_base_9slice_v01", "Base container for a rune energy bar, Nordic fantasy mobile game, premium 3D cartoon style. Magical metal frame with intricate runes, empty state, 9-slice ready, 256x32px, transparent background, cinematic lighting, game-ready asset, no text.")

generate_image("df_rune_bar_fill_9slice_v01", "Fill element for a rune energy bar, Nordic fantasy mobile game, premium 3D cartoon style. Cyan to golden gradient with floating rune particles, magical energy flow, 9-slice ready, 256x32px, transparent background, cinematic lighting, game-ready asset, no text.")
```

**Após geração**: Copiar para `assets/ui/bars/`

---

### LOTE 3: Botões (8 assets - ~14min)

```
generate_image("df_btn_primary_s_normal_v01", "Small primary button for mobile game UI, Nordic fantasy style, premium 3D cartoon. Cyan runic glow, brushed metal with carved runes, rounded rectangle, normal state, 128x48px, transparent background, cinematic lighting, subtle outline, game-ready asset, no text.")

generate_image("df_btn_primary_s_pressed_v01", "Small primary button for mobile game UI, Nordic fantasy style, premium 3D cartoon. Cyan runic glow, brushed metal, pressed state, slightly darker, compressed appearance, stronger inner glow, 128x48px, transparent background, cinematic lighting, game-ready asset, no text.")

generate_image("df_btn_primary_s_disabled_v01", "Small primary button for mobile game UI, Nordic fantasy style, premium 3D cartoon. Disabled state, desaturated, faded runes, no glow, grayed out, 128x48px, transparent background, cinematic lighting, game-ready asset, no text.")

generate_image("df_btn_primary_m_normal_v01", "Medium primary button for mobile game UI, Nordic fantasy style, premium 3D cartoon. Cyan runic glow, brushed metal with carved runes, rounded rectangle, normal state, 192x56px, transparent background, cinematic lighting, subtle outline, game-ready asset, no text.")

generate_image("df_btn_primary_l_normal_v01", "Large primary button for mobile game UI, Nordic fantasy style, premium 3D cartoon. Cyan runic glow, brushed metal with carved runes, rounded rectangle, normal state, 256x64px, transparent background, cinematic lighting, subtle outline, game-ready asset, no text.")

generate_image("df_btn_cta_battle_normal_v01", "Giant CTA button for Battle action, Nordic fantasy mobile game, premium 3D cartoon. Golden gradient with intense glow, layered depth, pulsating runic aura, epic appearance, normal state, 320x96px, transparent background, cinematic lighting, game-ready asset, no text.")

generate_image("df_btn_cta_battle_pressed_v01", "Giant CTA button for Battle action, Nordic fantasy mobile game, premium 3D cartoon. Golden gradient, pressed state, compressed, stronger glow burst, energy release effect, 320x96px, transparent background, cinematic lighting, game-ready asset, no text.")

generate_image("df_btn_icon_circle_normal_v01", "Circular icon button for mobile game UI, Nordic fantasy style, premium 3D cartoon. Brushed metal circle with subtle rune border, normal state, 64x64px, transparent background, cinematic lighting, game-ready asset, no icon inside (empty).")
```

**Após geração**: Copiar para `assets/ui/buttons/`

---

### LOTE 4: Baús Estáticos (6 assets - ~11min)

```
generate_image("df_chest_common_closed_v01", "Common wooden chest for mobile game, Nordic fantasy style, premium 3D cartoon. Simple wood with iron bands, small carved runes, closed state, isometric 3/4 view, 512x512px, transparent background, cinematic lighting, game-ready asset, no text.")

generate_image("df_chest_common_ready_v01", "Common wooden chest for mobile game, Nordic fantasy style, premium 3D cartoon. Ready to open state, glowing green aura, pulsating light from cracks, magical particles floating around, isometric 3/4 view, 512x512px, transparent background, cinematic lighting, game-ready asset, no text.")

generate_image("df_chest_common_opening_v01", "Common wooden chest for mobile game, Nordic fantasy style, premium 3D cartoon. Mid-opening state, lid slightly open, bright light bursting out, energy rays, magical explosion starting, isometric 3/4 view, 512x512px, transparent background, cinematic lighting, game-ready asset, no text.")

generate_image("df_chest_legendary_closed_v01", "Legendary ornate golden chest for mobile game, Nordic fantasy style, premium 3D cartoon. Intricate carvings, glowing runes, golden magical aura, epic appearance, closed state, isometric 3/4 view, 512x512px, transparent background, cinematic lighting, game-ready asset, no text.")

generate_image("df_chest_master_closed_v01", "Master ruby chest for mobile game, Nordic fantasy style, premium 3D cartoon. Ruby red theme, aggressive runes, intense magical aura, ultimate quality, closed state, isometric 3/4 view, 512x512px, transparent background, cinematic lighting, game-ready asset, no text.")

generate_image("df_chest_arena_closed_v01", "Arena Viking chest for mobile game, Nordic fantasy style, premium 3D cartoon. Wood with rope and ship elements, Nordic warrior theme, closed state, isometric 3/4 view, 512x512px, transparent background, cinematic lighting, game-ready asset, no text.")
```

**Após geração**: Copiar para `assets/ui/chests/`

---

### LOTE 5: Sprite Sheets (9 assets - ~18min)

```
generate_image("df_chest_opening_loop_sheet_v01", "Sprite sheet animation for chest opening loop, 12 frames, Nordic fantasy mobile game. Chest vibrating and glowing with increasing intensity, runic particles floating, 256x256px per frame, arranged in 4x3 grid, 1024x768px total, transparent background, cinematic lighting, game-ready asset.")

generate_image("df_chest_burst_reward_sheet_v01", "Sprite sheet animation for chest reward burst, 16 frames, Nordic fantasy mobile game. Explosive light burst with magical particles, runes flying outward, energy waves, 512x512px per frame, arranged in 4x4 grid, 2048x2048px total, transparent background, cinematic lighting, game-ready asset.")

generate_image("df_vfx_select_glow_loop_sheet_v01", "Sprite sheet animation for item selection glow, 12 frames loop, Nordic fantasy mobile game. Circular cyan runic glow pulsating smoothly, rotating runes, 128x128px per frame, arranged in 4x3 grid, 512x384px total, transparent background, game-ready asset.")

generate_image("df_vfx_press_feedback_sheet_v01", "Sprite sheet animation for button press feedback, 8 frames, Nordic fantasy mobile game. Quick cyan energy ripple expanding outward, 128x128px per frame, arranged in 4x2 grid, 512x256px total, transparent background, game-ready asset.")

generate_image("df_vfx_cta_rune_pulse_sheet_v01", "Sprite sheet animation for CTA button rune pulse, 16 frames loop, Nordic fantasy mobile game. Runic symbols glowing and fading in sequence, magical energy flow, 256x256px per frame, arranged in 4x4 grid, 1024x1024px total, transparent background, game-ready asset.")

generate_image("df_vfx_lightning_sparks_sheet_v01", "Sprite sheet animation for lightning VFX, 12 frames, Nordic fantasy mobile game. Electric cyan sparks and bolts, crackling energy, 256x256px per frame, arranged in 4x3 grid, 1024x768px total, transparent background, game-ready asset.")

generate_image("df_vfx_frost_shards_sheet_v01", "Sprite sheet animation for frost VFX, 12 frames, Nordic fantasy mobile game. Ice shards forming and shattering, blue crystalline particles, 256x256px per frame, arranged in 4x3 grid, 1024x768px total, transparent background, game-ready asset.")

generate_image("df_vfx_poison_smoke_loop_sheet_v01", "Sprite sheet animation for poison VFX, 16 frames loop, Nordic fantasy mobile game. Emerald green toxic smoke swirling, bubbling particles, 256x256px per frame, arranged in 4x4 grid, 1024x1024px total, transparent background, game-ready asset.")

generate_image("df_vfx_levelup_burst_sheet_v01", "Sprite sheet animation for level up effect, 16 frames, Nordic fantasy mobile game. Golden energy explosion with ascending runes, star particles, triumphant burst, 512x512px per frame, arranged in 4x4 grid, 2048x2048px total, transparent background, game-ready asset.")
```

**Após geração**: Copiar para `assets/ui/vfx/` e `assets/ui/chests/anim/`

---

## 📦 Pós-Geração

### 1. Organizar Assets
```powershell
# Mover para pastas corretas
Move-Item "*.png" "assets/ui/[categoria]/"
```

### 2. Corrigir Transparência (Importante!)
O gerador de imagens pode criar um fundo falso ou "sujo". Execute este script para limpar:
```powershell
# Requer: pip install rembg pillow
python scripts/fix_transparency.py
```

### 3. Corrigir Transparência (Importante!)
O gerador de imagens pode criar um fundo falso ou "sujo". Execute este script para limpar:
```powershell
# Requer: pip install rembg pillow
python scripts/fix_transparency.py
```

### 4. Cortar Bordas (Trim)
Remove o espaço vazio ao redor da imagem para otimizar o tamanho e o alinhamento:
```powershell
python scripts/trim_assets.py
```

### 5. Atualizar Código
- Verificar `df_assets_technical.dart`
- Testar widgets técnicos
- Validar sprite sheet metadata

### 6. Criar Atlas (Opcional)
- Usar ferramenta de texture packing
- Gerar JSON metadata
- Otimizar para mobile

---

## ✅ Checklist Pós-Integração

- [ ] Todos os 36 assets gerados
- [ ] Assets copiados para pastas corretas
- [ ] pubspec.yaml atualizado
- [ ] Código de assets atualizado
- [ ] Testes de 9-slice funcionando
- [ ] Sprite sheets animando corretamente
- [ ] Performance validada

---

**Total de Assets**: 36 novos (+ 21 existentes = 57/100)  
**Tempo Estimado**: ~65 minutos de geração  
**Próxima Fase**: Ícones, badges e assets restantes

---

**Criado**: 14/01/2026 00:35  
**Versão**: v1.0  
**Status**: Pronto para execução
