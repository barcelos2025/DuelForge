import bpy
import os
import math

# --- CONFIGURAÇÃO ---
# Caminho de saída relativo ao arquivo .blend
OUTPUT_PATH = "//render/"  

# Definição das animações: Nome, Frame Inicial, Frame Final, FPS (referência)
ANIMATIONS = {
    "idle": {"start": 1, "end": 24, "fps": 12},
    "walk": {"start": 30, "end": 54, "fps": 12},
    "attack": {"start": 60, "end": 80, "fps": 15},
    "death": {"start": 90, "end": 110, "fps": 15},
    # Adicione mais conforme necessário: "cast", "hit", etc.
}

# Direções a renderizar
DIRECTIONS = ["S", "SW", "W", "NW", "N", "NE", "E", "SE"]

# Ângulos de rotação para cada direção (em graus)
# Assumindo que a câmera está fixa em Y negativo (olhando para o Norte)
# e o modelo começa virado para Y negativo (Sul)
ROTATIONS = [0, 45, 90, 135, 180, 225, 270, 315] 

# Nome do objeto que será rotacionado (Armature ou Empty pai)
ROOT_OBJECT_NAME = "Root" 

# --------------------

def render_sprites():
    """
    Renderiza todas as animações em todas as direções configuradas.
    """
    scene = bpy.context.scene
    root_obj = bpy.data.objects.get(ROOT_OBJECT_NAME)
    
    if not root_obj:
        print(f"ERRO: Objeto '{ROOT_OBJECT_NAME}' não encontrado na cena.")
        print("Verifique se o nome está correto ou se o objeto existe.")
        return

    # Salvar estado original para restaurar depois
    original_rot_z = root_obj.rotation_euler.z
    original_filepath = scene.render.filepath
    original_start = scene.frame_start
    original_end = scene.frame_end

    print(f"Iniciando renderização de {len(ANIMATIONS)} animações em {len(DIRECTIONS)} direções...")

    for anim_name, data in ANIMATIONS.items():
        print(f"--- Renderizando Animação: {anim_name} ---")
        
        # Configurar Timeline
        scene.frame_start = data["start"]
        scene.frame_end = data["end"]
        
        for i, direction in enumerate(DIRECTIONS):
            print(f"   Direção: {direction}")
            
            # Rotacionar Objeto
            # Converter graus para radianos
            angle_rad = math.radians(ROTATIONS[i])
            root_obj.rotation_euler.z = angle_rad

            # Configurar Caminho de Saída
            # Estrutura: //render/<anim_name>/<anim_name>_<direction>_<frame>.png
            # Ex: //render/walk/walk_S_0001.png
            
            # Criar pasta específica para a animação se não existir (opcional, o Blender cria pastas no render)
            # Mas para organização, vamos colocar tudo numa pasta por animação
            folder_name = f"{anim_name}"
            file_prefix = f"{anim_name}_{direction}_"
            
            full_output_path = os.path.join(OUTPUT_PATH, folder_name, file_prefix)
            
            scene.render.filepath = full_output_path

            # Renderizar Animação
            # write_still=True garante que salve o arquivo
            bpy.ops.render.render(animation=True, write_still=True)
    
    # Restaurar estado original
    root_obj.rotation_euler.z = original_rot_z
    scene.render.filepath = original_filepath
    scene.frame_start = original_start
    scene.frame_end = original_end
    
    print("=== Renderização Concluída com Sucesso! ===")

if __name__ == "__main__":
    render_sprites()
