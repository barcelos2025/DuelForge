# DuelForge 3D to 2D Spritesheet Pipeline

Este documento define o pipeline técnico para transformar modelos 3D (Blender) em sprites 2D com estilo "Fake 3D" para o DuelForge.

## 1. Especificações Técnicas

### Ferramentas
- **Software Principal**: Blender 4.0+
- **Motor de Render**: EEVEE (para velocidade e estilo toon) ou Cycles (se precisar de bake complexo, mas EEVEE é preferido para toon).

### Resolução de Saída (por frame)
| Tipo de Unidade | Resolução | Exemplo |
|-----------------|-----------|---------|
| **Tropas Comuns** | 256x256 px | Arqueiras, Goblins |
| **Lendárias/Boss** | 384x384 px | Rei Bárbaro, Dragão |
| **Torres/Construções** | 512x512 px | Torre do Rei, Canhão |

### Taxa de Quadros (FPS)
O jogo roda a 60 FPS, mas as animações devem ser "bakeadas" em taxas menores para economizar memória e dar estilo.
- **Walk / Idle**: 12 FPS
- **Attack / Cast / Hit / Death**: 15 FPS

### Direções de Renderização
Para um efeito 3D convincente em visão isométrica/top-down, renderizamos em 8 ângulos.
- **N** (Costas/Cima)
- **NE**
- **E** (Direita)
- **SE**
- **S** (Frente/Baixo)
- **SW**
- **W** (Esquerda - pode ser espelhado do E se o modelo for simétrico)
- **NW** (pode ser espelhado do NE)

*Mínimo Aceitável (MVP)*: 2 Direções (S - Frente/Baixo, N - Costas/Cima) + Espelhamento horizontal via código.

## 2. Configuração do Blender (Checklist)

### Câmera
- [ ] **Tipo**: Ortográfica (Orthographic).
- [ ] **Ângulo**: 45 graus (Isométrico padrão) ou 60 graus (Top-down mais inclinado, estilo Clash).
  - *Recomendação DuelForge*: Câmera a 45º de inclinação no eixo X.
- [ ] **Scale**: Ajustar para que a unidade ocupe 80% do frame (deixar margem para VFX/Armas).

### Iluminação (Estilo Cartoon)
- [ ] **Key Light (Sol)**: Luz principal, levemente amarelada, vindo de cima-esquerda.
- [ ] **Fill Light**: Luz azulada suave vindo do lado oposto para preencher sombras (evitar preto total).
- [ ] **Rim Light (Backlight)**: Luz forte vindo de trás da unidade para criar silhueta e destacar do fundo. Essencial para leitura visual.
- [ ] **Ambient Occlusion**: Ligado (Distance curta) para contato com o chão.

### Materiais (Toon Shading)
- [ ] **Shader**: Usar `Shader To RGB` no EEVEE com `ColorRamp` para criar faixas de cor duras (Cel Shading).
- [ ] **Outline**:
  - Método 1 (Simples): Grease Pencil "Line Art" modifier.
  - Método 2 (Inverted Hull): Modificador Solidify com Normais invertidas e material preto (Backface Culling). *Recomendado para performance no render*.

### Fundo
- [ ] **Transparência**: Render Properties > Film > Transparent (Checked).

## 3. Estrutura de Diretórios e Naming Convention

### Estrutura de Pastas do Projeto (Assets)
```
assets/
└── units/
    └── <unit_id>/ (ex: df_unit_archer_v01)
        ├── source/ (arquivos .blend, texturas originais)
        ├── sprites/ (pngs individuais renderizados)
        │   ├── idle_s/
        │   ├── walk_s/
        │   └── ...
        └── atlas/ (spritesheets finais e json)
            ├── archer_idle.png
            ├── archer_idle.json
            ├── archer_walk.png
            └── archer_walk.json
```

### Naming Convention (Arquivos Exportados)
Formato: `<anim>_<dir>_<frame>.png`
- `anim`: idle, walk, attack, hit, death, cast
- `dir`: n, ne, e, se, s, sw, w, nw
- `frame`: 0000, 0001, ...

Exemplo: `walk_s_0001.png` (Andando, Sul/Frente, Frame 1)

## 4. Script de Automação (Python para Blender)

Copie e cole este script na aba "Scripting" do Blender para renderizar automaticamente todas as direções.

```python
import bpy
import os
import math

# --- CONFIGURAÇÃO ---
OUTPUT_PATH = "//render/"  # Caminho relativo ao .blend
ANIMATIONS = {
    "idle": {"start": 1, "end": 24, "fps": 12},
    "walk": {"start": 30, "end": 54, "fps": 12},
    "attack": {"start": 60, "end": 80, "fps": 15},
    "death": {"start": 90, "end": 110, "fps": 15}
}
DIRECTIONS = ["S", "SW", "W", "NW", "N", "NE", "E", "SE"]
# Ângulos de rotação para cada direção (assumindo câmera fixa em Y negativo)
ROTATIONS = [0, 45, 90, 135, 180, 225, 270, 315] 

# Objeto "Root" ou "Armature" que será rotacionado
ROOT_OBJECT_NAME = "Root" 
# --------------------

def render_sprites():
    scene = bpy.context.scene
    root_obj = bpy.data.objects.get(ROOT_OBJECT_NAME)
    
    if not root_obj:
        print(f"Erro: Objeto '{ROOT_OBJECT_NAME}' não encontrado.")
        return

    # Salvar rotação original
    original_rot = root_obj.rotation_euler.z

    for anim_name, data in ANIMATIONS.items():
        # Configurar Timeline
        scene.frame_start = data["start"]
        scene.frame_end = data["end"]
        # Nota: FPS no Blender é global, então renderizamos tudo e ajustamos playback no jogo,
        # ou ajustamos o 'Step' do render se quisermos pular frames.
        # Para simplificar, renderizamos todos os frames do range.
        
        for i, direction in enumerate(DIRECTIONS):
            # Rotacionar Objeto
            # Converter graus para radianos
            angle_rad = math.radians(ROTATIONS[i])
            root_obj.rotation_euler.z = angle_rad

            # Configurar Saída
            # Ex: //render/walk_S/walk_S_
            folder = os.path.join(OUTPUT_PATH, f"{anim_name}_{direction}")
            if not os.path.exists(bpy.path.abspath(folder)):
                os.makedirs(bpy.path.abspath(folder))
            
            scene.render.filepath = os.path.join(folder, f"{anim_name}_{direction}_")

            # Renderizar Animação
            bpy.ops.render.render(animation=True)
    
    # Restaurar
    root_obj.rotation_euler.z = original_rot
    print("Renderização Concluída!")

# Descomente para rodar
# render_sprites()
```

## 5. Pós-Processamento (Geração de Atlas)

Após renderizar os frames individuais, use uma ferramenta como **TexturePacker** ou um script simples (ImageMagick/Python Pillow) para criar o Spritesheet.

### Formato do Atlas JSON (Compatível com Flame)
O Flame engine suporta nativamente o formato JSON do TexturePacker (Hash ou Array).

Exemplo de estrutura desejada no JSON:
```json
{
  "frames": {
    "walk_s_0001.png": {
      "frame": {"x":2, "y":2, "w":256, "h":256},
      "rotated": false,
      "trimmed": true,
      "spriteSourceSize": {"x":0,"y":0,"w":256,"h":256},
      "sourceSize": {"w":256,"h":256}
    },
    ...
  },
  "meta": {
    "image": "archer_walk.png",
    "size": {"w": 1024, "h": 1024},
    "scale": "1"
  }
}
```

## 6. Passo a Passo para o Artista

1.  **Modelagem & Rigging**: Crie o personagem no Blender. Mantenha a contagem de polígonos razoável, mas o foco é na silhueta.
2.  **Materiais**: Aplique materiais com cores chapadas (Diffuse) e configure o Shader To RGB para o efeito Toon. Adicione o Outline (Inverted Hull).
3.  **Animação**: Crie as ações na Timeline (Idle, Walk, Attack, etc.). Marque os frames de início e fim.
4.  **Setup de Cena**:
    *   Posicione a Câmera Ortho.
    *   Configure as Luzes (Sol + Rim Light).
    *   Ative "Transparent" no Film.
    *   Defina a resolução (ex: 256x256).
5.  **Scripting**:
    *   Abra a aba Scripting.
    *   Cole o script fornecido acima.
    *   Ajuste o nome do objeto `ROOT_OBJECT_NAME` (geralmente a Armature ou um Empty pai).
    *   Ajuste os ranges de frames no dicionário `ANIMATIONS`.
    *   Execute o script.
6.  **Pack**: Use o TexturePacker para juntar os PNGs gerados em um único `.png` e `.json` por animação (ou um atlas gigante por unidade, se couber em 2048x2048).
7.  **Import**: Copie os arquivos `.png` e `.json` para `assets/images/units/<unit_id>/` no projeto Flutter.
