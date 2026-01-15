import bpy
import os
import json
import math

# ==========================================
# CONFIGURAÇÃO DO USUÁRIO
# ==========================================

# ID da Unidade (Nome da pasta e prefixo dos arquivos)
UNIT_ID = "shield_warrior"

# Tamanho do Frame (256, 384, 512)
FRAME_SIZE = 256

# Diretório de Saída (Use barras normais /)
# Dica: Use o caminho absoluto para a pasta assets do seu projeto
OUTPUT_DIR = "C:/Users/Note/Desktop/DuelForge/assets/images/units"

# Lista de Animações para Renderizar
# Formato: {"name": "suffix", "action": "BlenderActionName", "fps": 12, "hit_frame": 6}
# Se "action" for None, usa a ação atualmente ativa no Blender.
ANIMATIONS = [
    {"name": "idle",   "action": "ShieldWarrior_Idle",   "fps": 12},
    {"name": "walk",   "action": "ShieldWarrior_Walk",   "fps": 12},
    {"name": "attack", "action": "ShieldWarrior_Attack", "fps": 15, "hit_frame": 8}, # Exemplo de hit frame
    {"name": "death",  "action": "ShieldWarrior_Death",  "fps": 10},
]

# Configuração de Pivô (Ancoragem)
# Flame usa Top-Left como (0,0) e Bottom-Right como (1,1).
# Para "Feet Pivot" (pés no chão), geralmente X=0.5 (centro) e Y=0.9 (perto do fundo).
PIVOT_X = 0.5
PIVOT_Y = 0.9

# Direções para renderizar (Angulos em graus no eixo Z)
# 8 Direções: [0, 45, 90, 135, 180, 225, 270, 315]
# Sufixos: n, nw, w, sw, s, se, e, ne (Ajuste a ordem conforme sua câmera/rig)
# Assumindo câmera em -Y olhando para +Y (Frontal):
# 0=S, 45=SE, 90=E, 135=NE, 180=N, 225=NW, 270=W, 315=SW
DIRECTIONS = [
    {"suffix": "s",  "angle": 0},
    {"suffix": "se", "angle": 45},
    {"suffix": "e",  "angle": 90},
    {"suffix": "ne", "angle": 135},
    {"suffix": "n",  "angle": 180},
    {"suffix": "nw", "angle": 225},
    {"suffix": "w",  "angle": 270},
    {"suffix": "sw", "angle": 315},
]

# Objeto "Root" para rotacionar (Geralmente a Armature ou um Empty pai)
ROOT_OBJECT_NAME = "Armature" 

# ==========================================
# SCRIPT (NÃO ALTERE ABAIXO)
# ==========================================

def setup_render_settings():
    scene = bpy.context.scene
    scene.render.resolution_x = FRAME_SIZE
    scene.render.resolution_y = FRAME_SIZE
    scene.render.resolution_percentage = 100
    scene.render.film_transparent = True
    scene.render.image_settings.file_format = 'PNG'
    scene.render.image_settings.color_mode = 'RGBA'

def get_action_range(action_name):
    if action_name not in bpy.data.actions:
        print(f"Action '{action_name}' não encontrada!")
        return 0, 0
    action = bpy.data.actions[action_name]
    return int(action.frame_range[0]), int(action.frame_range[1])

def render_animation(anim_config):
    scene = bpy.context.scene
    root_obj = bpy.data.objects.get(ROOT_OBJECT_NAME)
    
    if not root_obj:
        print(f"Objeto Root '{ROOT_OBJECT_NAME}' não encontrado.")
        return

    # Configurar Action
    action_name = anim_config["action"]
    if action_name:
        if root_obj.animation_data is None:
            root_obj.animation_data_create()
        
        if action_name in bpy.data.actions:
            root_obj.animation_data.action = bpy.data.actions[action_name]
            start_frame, end_frame = get_action_range(action_name)
        else:
            print(f"Action {action_name} não existe.")
            return
    else:
        start_frame = scene.frame_start
        end_frame = scene.frame_end

    # Loop por direções
    for direction in DIRECTIONS:
        angle = direction["angle"]
        suffix = direction["suffix"]
        
        # Rotacionar Objeto
        root_obj.rotation_euler[2] = math.radians(angle)
        
        # Preparar dados para spritesheet
        frames_data = []
        temp_dir = bpy.app.tempdir
        
        # Renderizar Frames
        frame_count = (end_frame - start_frame) + 1
        print(f"Renderizando {anim_config['name']} ({suffix}) - {frame_count} frames...")
        
        for i, frame in enumerate(range(start_frame, end_frame + 1)):
            scene.frame_set(frame)
            filename = f"temp_{i:03d}.png"
            filepath = os.path.join(temp_dir, filename)
            scene.render.filepath = filepath
            bpy.ops.render.render(write_still=True)
            frames_data.append(filepath)

        # Montar Spritesheet (Grid)
        # Calcula grid quadrado ou retangular
        grid_cols = math.ceil(math.sqrt(frame_count))
        grid_rows = math.ceil(frame_count / grid_cols)
        
        sheet_width = grid_cols * FRAME_SIZE
        sheet_height = grid_rows * FRAME_SIZE
        
        # Criar nova imagem
        sheet_name = f"{UNIT_ID}_{anim_config['name']}_{suffix}"
        sprite_sheet = bpy.data.images.new(sheet_name, width=sheet_width, height=sheet_height, alpha=True)
        
        # Pixel buffer (inicia vazio/transparente)
        # Blender images are flattened arrays of float (R, G, B, A)
        # Initialize with 0.0
        pixels = [0.0] * (sheet_width * sheet_height * 4)
        
        for idx, frame_path in enumerate(frames_data):
            try:
                img = bpy.data.images.load(frame_path)
                
                # Calcular posição no grid
                col = idx % grid_cols
                row = idx // grid_cols
                
                # Inverter row para começar do topo (Blender Y é bottom-up)
                inv_row = (grid_rows - 1) - row
                
                start_x = col * FRAME_SIZE
                start_y = inv_row * FRAME_SIZE
                
                # Copiar pixels
                frame_pixels = list(img.pixels)
                
                for y in range(FRAME_SIZE):
                    for x in range(FRAME_SIZE):
                        # Pixel source index
                        src_idx = (y * FRAME_SIZE + x) * 4
                        
                        # Pixel dest index
                        dest_x = start_x + x
                        dest_y = start_y + y
                        dest_idx = (dest_y * sheet_width + dest_x) * 4
                        
                        pixels[dest_idx] = frame_pixels[src_idx]         # R
                        pixels[dest_idx+1] = frame_pixels[src_idx+1]     # G
                        pixels[dest_idx+2] = frame_pixels[src_idx+2]     # B
                        pixels[dest_idx+3] = frame_pixels[src_idx+3]     # A
                
                # Limpar imagem temporária
                bpy.data.images.remove(img)
                os.remove(frame_path)
                
            except Exception as e:
                print(f"Erro processando frame {idx}: {e}")

        # Salvar Spritesheet
        sprite_sheet.pixels = pixels
        output_path = os.path.join(OUTPUT_DIR, UNIT_ID)
        if not os.path.exists(output_path):
            os.makedirs(output_path)
            
        final_image_path = os.path.join(output_path, f"{sheet_name}.png")
        sprite_sheet.filepath_raw = final_image_path
        sprite_sheet.file_format = 'PNG'
        sprite_sheet.save()
        print(f"Salvo: {final_image_path}")
        
        # Gerar JSON
        json_data = {
            "id": sheet_name,
            "frameWidth": FRAME_SIZE,
            "frameHeight": FRAME_SIZE,
            "frameCount": frame_count,
            "fps": anim_config["fps"],
            "columns": grid_cols,
            "rows": grid_rows,
            "pivot": {"x": PIVOT_X, "y": PIVOT_Y},
            "hitFrame": anim_config.get("hit_frame", -1), # -1 se não definido
            "animations": {
                anim_config["name"]: list(range(frame_count))
            }
        }
        
        json_path = os.path.join(output_path, f"{sheet_name}.json")
        with open(json_path, 'w') as f:
            json.dump(json_data, f, indent=2)
            
        # Limpar memória
        bpy.data.images.remove(sprite_sheet)

setup_render_settings()
print("=== Iniciando Renderização em Lote ===")
for anim in ANIMATIONS:
    render_animation(anim)
print("=== Concluído! ===")
