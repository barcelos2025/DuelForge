# Template de Cena Blender - DuelForge (Fake AAA Toon)

Este guia descreve passo a passo como configurar uma cena no Blender (Eevee) para renderizar spritesheets com qualidade "Cartoon Premium" (estilo Clash Royale/LoL).

Salve o resultado final como `blender_template_duelforge.blend`.

## 1. Configuração da Cena e Render (Eevee)

1.  **Engine**: Selecione **Eevee**.
2.  **Sampling**:
    *   **Render**: 64 samples (suficiente para toon).
    *   **Viewport**: 16 samples.
3.  **Ambient Occlusion (AO)**:
    *   [x] Habilitar.
    *   **Distance**: 0.2 m (ajuste conforme a escala, deve ser sutil nas fendas).
    *   **Factor**: 1.0.
    *   **Trace Precision**: 0.5.
4.  **Bloom** (Opcional, para magia/VFX):
    *   [x] Habilitar.
    *   **Intensity**: 0.05 (bem suave).
5.  **Film**:
    *   [x] **Transparent** (Essencial para sprites).
6.  **Color Management**:
    *   **View Transform**: **Standard** (NÃO use Filmic ou AgX para toon, pois eles desbotam as cores saturadas).
    *   **Look**: Medium High Contrast.

## 2. Configuração de Câmera (Isométrica)

1.  Adicione uma Câmera (`Shift + A` > Camera).
2.  Nas propriedades da Câmera (ícone verde):
    *   **Type**: **Orthographic**.
    *   **Orthographic Scale**: 4.0 (Ajuste isso para dar zoom in/out no personagem sem mover a câmera).
3.  Posicionamento (Transform):
    *   **Location**: X=10, Y=-10, Z=10 (apenas para afastar).
    *   **Rotation**:
        *   **X**: `54.736°` (Valor exato para True Isometric).
        *   **Y**: `0°`.
        *   **Z**: `45°`.
    *   *Dica*: Isso garante que as linhas do grid se alinhem perfeitamente com os pixels diagonais.

## 3. Iluminação (Setup de 3 Pontos)

Crie uma coleção chamada `Lighting`.

### A. Key Light (Sol Principal)
*   **Tipo**: Sun Light.
*   **Cor**: Amarelo levemente quente (Hex: `#FFF5E0`).
*   **Strength**: 4.0.
*   **Angle**: 15° (sombras levemente suaves).
*   **Rotação**: A luz deve vir de "cima e esquerda" em relação à câmera. Tente rotacionar para iluminar o rosto/frente do personagem.
    *   Sugestão: Rotação Z ~ 110°, X ~ 45°.

### B. Fill Light (Preenchimento)
*   **Tipo**: Area Light (Shape: Disk).
*   **Cor**: Azulado frio (Hex: `#DCEEFF`).
*   **Power**: 150 W.
*   **Posição**: Lado oposto da Key Light, mais baixo. Ilumina as sombras escuras.

### C. Rim Light (Recorte)
*   **Tipo**: Spot Light ou Area Light.
*   **Cor**: Branco puro ou levemente ciano.
*   **Power**: 300 W (forte).
*   **Posição**: Atrás do personagem, apontando para as costas/cabeça.
*   **Objetivo**: Criar uma borda iluminada na silhueta para destacar do fundo.

## 4. Material Toon (Cel Shading)

Este é o material base. Você pode duplicá-lo e mudar a cor base para diferentes partes do personagem.

1.  No **Shader Editor**:
2.  Delete o *Principled BSDF* (ou use-o conectado ao Shader to RGB se quiser usar as propriedades dele, mas o método Diffuse é mais limpo para toon puro).
    *   **Setup Recomendado**:
        `Diffuse BSDF` -> `Shader to RGB` -> `ColorRamp` -> `Output Material (Surface)`.
3.  **Configuração do ColorRamp**:
    *   **Interpolation**: **Constant** (Isso cria as bandas duras).
    *   **Stops (Bandas)**:
        *   Posição 0.0 - 0.4: Cor da Sombra (Escura/Fria).
        *   Posição 0.4 - 0.7: Cor Base (Tom médio).
        *   Posição 0.7 - 1.0: Highlight (Claro).
    *   *Ajuste as posições dos sliders enquanto observa o render para controlar a quantidade de sombra.*

## 5. Outline (Borda Preta) - Método "Inverted Hull"

Este método é o mais estável para jogos e funciona perfeitamente no Eevee.

### Passo 1: Material de Outline
1.  Crie um novo slot de material no objeto.
2.  Nomeie como `Outline_Mat`.
3.  No Shader Editor:
    *   Use um nó **Emission**.
    *   **Color**: Preto (Hex `#000000`).
    *   **Strength**: 1.0.
4.  Nas configurações do Material (aba lateral direita) > **Settings**:
    *   [x] **Backface Culling** (CRUCIAL: Isso faz a mágica acontecer).
    *   Blend Mode: Opaque.
    *   Shadow Mode: None.

### Passo 2: Modificador Solidify
1.  Selecione o objeto/mesh.
2.  Adicione um modificador **Solidify**.
3.  Configure EXATAMENTE assim:
    *   **Thickness**: `-0.02 m` (Valor NEGATIVO é importante. Ajuste a espessura conforme a escala do modelo).
    *   **Offset**: `1.0`.
    *   [x] **Flip Normals**.
    *   **Material Index Offset**: `1` (Isso diz para usar o 2º material da lista, que deve ser o `Outline_Mat`).
    *   [x] **High Quality Normals** (Opcional, melhora cantos).

## 6. Configurações de Output

1.  **Resolution**:
    *   X: `256 px`.
    *   Y: `256 px`.
    *   (Ou 384/512 conforme o tipo de unidade).
2.  **Output Format**:
    *   File Format: **PNG**.
    *   Color: **RGBA** (Alpha é obrigatório).
    *   Color Depth: **8** (16 é exagero para sprites mobile).
    *   Compression: **15%**.

## 7. Como Salvar e Usar

1.  Limpe a cena de objetos desnecessários (cubo padrão).
2.  Deixe um objeto "Placeholder" (ex: a macaca Suzanne) com o Material Toon e o Modificador Outline aplicados para teste.
3.  Vá em **File > Save As...** e nomeie como `blender_template_duelforge.blend`.

### Workflow de Uso:
1.  Abra o template.
2.  Importe seu modelo 3D (File > Import).
3.  Aplique o **Material Toon** (copie e mude as cores do ColorRamp).
4.  Adicione o slot do **Outline_Mat** na lista de materiais do objeto.
5.  Copie o modificador **Solidify** do placeholder para o seu modelo (`Ctrl+L` > Copy Modifiers).
6.  Ajuste o **Orthographic Scale** da câmera para enquadrar (não mova a câmera!).
7.  Renderize (`F12`).
