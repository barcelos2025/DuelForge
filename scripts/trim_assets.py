import os
import sys
from pathlib import Path
from PIL import Image

def trim_image(file_path):
    print(f"✂️  Processando: {file_path.name}...")
    
    try:
        img = Image.open(file_path)
        
        # Converter para RGBA se não for
        if img.mode != 'RGBA':
            img = img.convert('RGBA')
            
        # Obter a bounding box do conteúdo não transparente
        # getbbox() retorna (left, upper, right, lower) ou None se for tudo transparente
        bbox = img.getbbox()
        
        if bbox:
            # Se a imagem já é do tamanho do bbox, não precisa cortar
            if bbox == (0, 0, img.width, img.height):
                print(f"   Ignorado (já otimizado): {file_path.name}")
                return False
                
            # Cortar a imagem
            cropped_img = img.crop(bbox)
            
            # Salvar sobrescrevendo
            cropped_img.save(file_path)
            
            original_area = img.width * img.height
            new_area = cropped_img.width * cropped_img.height
            reduction = 100 - (new_area / original_area * 100)
            
            print(f"✅ Cortado: {file_path.name} (Redução de {reduction:.1f}%)")
            return True
        else:
            print(f"⚠️  Aviso: Imagem totalmente transparente: {file_path.name}")
            return False
            
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
    print("Iniciando corte de bordas transparentes...")
    
    trimmed_count = 0
    
    for png_file in png_files:
        # Ignorar arquivos que não devem ser cortados (ex: 9-slice que precisam de tamanho fixo?)
        # Por enquanto vamos cortar tudo, mas em 9-slice isso pode alterar o center/edge se não for cuidadoso.
        # Para 9-slice, geralmente queremos manter as proporções se foram geradas especificamente (ex: 128x128).
        # Mas se o gerador criou borda vazia extra, o corte é bom.
        # VAMOS ADICIONAR UMA LISTA DE EXCLUSÃO SE NECESSÁRIO.
        
        if trim_image(png_file):
            trimmed_count += 1
            
    print("-" * 30)
    print(f"🏁 Concluído! {trimmed_count} imagens otimizadas.")

if __name__ == "__main__":
    main()
