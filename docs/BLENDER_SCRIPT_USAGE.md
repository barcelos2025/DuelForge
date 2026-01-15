# Como usar o Script de Renderização Automática

Este guia explica como usar o script `scripts/blender_spritesheet_gen.py` dentro do Blender para gerar seus assets finais.

## 1. Preparação

1.  Abra seu arquivo `.blend` com o personagem já riggado e animado (seguindo o pipeline Mixamo).
2.  Certifique-se de que todas as animações (Idle, Walk, Attack, etc.) estão disponíveis como **Actions** no Blender.
3.  Verifique se a câmera está configurada corretamente (Isométrica).
4.  Verifique se o objeto "Root" (geralmente a Armature) está na origem (0,0,0) e sem rotação inicial.

## 2. Configurando o Script

1.  No Blender, vá para a aba **Scripting** (topo da tela).
2.  Clique em **Open** e navegue até `DuelForge/scripts/blender_spritesheet_gen.py`.
3.  Edite a seção **CONFIGURAÇÃO DO USUÁRIO** no topo do script:

```python
# ID da Unidade (Nome da pasta e prefixo dos arquivos)
UNIT_ID = "shield_warrior"  # <--- Mude para o ID do seu personagem

# Tamanho do Frame
FRAME_SIZE = 256

# Lista de Animações
# Mapeie o nome que o jogo usa ("walk") para o nome da Action no Blender ("ShieldWarrior_Walk")
ANIMATIONS = [
    {"name": "idle",   "action": "ShieldWarrior_Idle",   "fps": 12},
    {"name": "walk",   "action": "ShieldWarrior_Walk",   "fps": 12},
    # ... adicione outras
]

# Objeto Root
ROOT_OBJECT_NAME = "Armature" # <--- Verifique se o nome da sua Armature é este
```

## 3. Executando

1.  Com o script aberto no editor de texto do Blender, pressione o botão **Run Script** (ícone de "Play" ▶️ no topo do editor de texto).
2.  Abra o console do sistema (Window > Toggle System Console) para ver o progresso.
    *   O Blender pode "congelar" visualmente enquanto processa. Isso é normal. Olhe o console para ver o status.

## 4. Resultado

O script irá criar automaticamente:
*   Pasta: `assets/images/units/<unit_id>/`
*   Arquivos PNG: `<unit_id>_<anim>_<dir>.png` (Spritesheet em grid)
*   Arquivos JSON: `<unit_id>_<anim>_<dir>.json` (Metadados para o Flame)

## 5. Dicas Importantes

*   **Lentidão**: O script manipula pixels em Python puro para criar o grid. Para sprites 256x256 é rápido, mas para 512x512 com muitos frames pode levar alguns segundos por animação.
*   **Direções**: O script rotaciona o objeto `ROOT_OBJECT_NAME`. Se sua iluminação for fixa na cena (não parentada à câmera), isso fará a luz bater corretamente em diferentes lados do personagem conforme ele gira, o que é ideal.
*   **Erro "Action não encontrada"**: Verifique se o nome no `ANIMATIONS` bate exatamente com o nome no Action Editor do Blender.
