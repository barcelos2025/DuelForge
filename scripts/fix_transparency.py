import os
import sys
from pathlib import Path
from PIL import Image
import io

# Tenta importar rembg, se não existir avisa o usuário
try:
    from rembg import remove
except ImportError:
    print("❌ Biblioteca 'rembg' não encontrada.")
    print("Por favor, instale executando:")
    print("pip install rembg pillow")
    sys.exit(1)

def process_image(file_path):
    print(f"🔄 Processando: {file_path.name}...")
    
    try:
        # Ler a imagem
        with open(file_path, 'rb') as i:
            input_data = i.read()
            
        # Remover fundo
        output_data = remove(input_data)
        
        # Salvar (sobrescrevendo)
        with open(file_path, 'wb') as o:
            o.write(output_data)
            
        print(f"✅ Sucesso: {file_path.name}")
        return True
    except Exception as e:
        print(f"❌ Erro ao processar {file_path.name}: {e}")
        return False

def main():
    # Caminho base dos assets
    base_dir = Path("assets/ui")
    
    if not base_dir.exists():
        print(f"❌ Diretório não encontrado: {base_dir}")
        return

    print(f"📂 Buscando imagens PNG em: {base_dir}")
    
    # Encontrar todos os PNGs recursivamente
    png_files = list(base_dir.rglob("*.png"))
    
    if not png_files:
        print("⚠️ Nenhuma imagem PNG encontrada.")
        return

    print(f"📊 Total de imagens encontradas: {len(png_files)}")
    print("Iniciando remoção de fundo (Isso pode demorar um pouco na primeira vez)...")
    
    success_count = 0
    
    for png_file in png_files:
        # Ignorar arquivos que já parecem processados ou de backup se houver
        if "_backup" in png_file.name:
            continue
            
        if process_image(png_file):
            success_count += 1
            
    print("-" * 30)
    print(f"🏁 Concluído! {success_count}/{len(png_files)} imagens processadas.")

if __name__ == "__main__":
    main()
