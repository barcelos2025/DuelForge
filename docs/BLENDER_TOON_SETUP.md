# Blender Toon Shading & Outline Setup (DuelForge Style)

Este guia detalha o setup exato para conseguir o visual "Cartoon/Anime" limpo no Blender (Eevee), ideal para renderizar sprites.

## 1. Configuração de Render (Eevee)

O Eevee é recomendado pela velocidade e suporte nativo ao nó "Shader to RGB".

1.  **Render Engine**: Eevee
2.  **Sampling**:
    *   Render: 64 (Suficiente para toon)
    *   Viewport: 16
3.  **Film**:
    *   **Transparent**: **ATIVADO** (Essencial para sprites)
4.  **Color Management**:
    *   View Transform: **Standard** (Não use AgX ou Filmic, pois eles lavam as cores do toon)
    *   Look: Medium High Contrast (Opcional, para mais "pop")
5.  **Shadows**:
    *   Cube Size: 1024px
    *   Cascade Size: 1024px
    *   High Bitdepth: Ativado
    *   Soft Shadows: **DESATIVADO** (Queremos sombras duras para cel shading)

## 2. Material Cel Shading (Shader Setup)

Este material cria faixas de cores duras (2-3 tons).

### Node Tree
Conecte os nós nesta ordem:

1.  **Principled BSDF** (ou Diffuse BSDF)
    *   Base Color: Sua cor/textura base.
    *   Roughness: 1.0 (Totalmente fosco).
    *   Specular: 0.0 (Remove brilhos realistas, vamos controlar isso manualmente se precisar).
2.  **Shader to RGB**
    *   Conecte a saída `BSDF` do Principled na entrada `Shader` deste nó.
    *   *Nota: Só funciona no Eevee.*
3.  **ColorRamp**
    *   Conecte a saída `Color` do Shader to RGB na entrada `Fac` do ColorRamp.
    *   **Interpolation**: **Constant** (Isso cria as bordas duras).
    *   **Stops (Configuração de 3 Tons)**:
        *   Posição 0.0 - 0.4: Cor da Sombra (Ex: Azul escuro ou Preto com Alpha reduzido, ou Multiplicação). *Dica: Use MixRGB em Multiply depois do ColorRamp para tingir a textura original.*
        *   Posição 0.4 - 0.5: Tom Médio (Opcional).
        *   Posição 0.5 - 1.0: Branco (Luz).
4.  **MixRGB (Multiply)**
    *   Entrada 1: Sua Textura de Cor Original.
    *   Entrada 2: Saída do ColorRamp.
    *   Saída: Surface do Material Output.

### Dica Pro (Rim Light no Material)
Para adicionar o Rim Light (luz de recorte) via shader:
1.  Adicione um nó **Fresnel** ou **Layer Weight**.
2.  Conecte em um **ColorRamp** (Constant) para afiar a borda.
3.  Some (**Add** ou **Mix - Screen**) esse resultado ao final do seu shader, antes do Output. Isso garante que a silhueta brilhe independente da luz.

## 3. Outline (Inverted Hull Method)

Este é o método mais robusto para jogos e sprites, pois gera linhas geométricas limpas que não variam com o zoom da câmera de forma estranha.

1.  Vá na aba **Modifiers** do seu objeto.
2.  Adicione um modificador **Solidify**.
3.  **Configurações do Solidify**:
    *   **Thickness**: Valor negativo (ex: `-0.02m`). Ajuste conforme a espessura desejada.
    *   **Offset**: `1.0`
    *   **Flip Normals**: **ATIVADO**
    *   **Material Index Offset**: `1` (Isso diz para usar o segundo material da lista).
4.  Vá na aba **Materials**.
5.  Adicione um segundo material (slot 2). Chame de `Outline_Mat`.
6.  **Configuração do Material Outline**:
    *   **Surface**: Emission (Cor Preta ou cor escura da unidade).
    *   **Settings** (Aba Material > Settings):
        *   **Backface Culling**: **ATIVADO** (O segredo! Isso faz a face da frente do "casco" invertido desaparecer, deixando só as bordas de trás visíveis).
    *   **Shadow Mode**: None.

*Como salvar preset*: Não dá para salvar modificadores como preset global facilmente, mas você pode criar um objeto "Template" com esse setup e usar `Ctrl+L > Copy Modifiers` para outros objetos.

## 4. Iluminação (Lighting Setup)

1.  **Sun Light (Principal)**:
    *   Angle: 45° (Vindo de cima/esquerda).
    *   Strength: Ajuste até o branco do ColorRamp aparecer onde deseja.
    *   Shadow: Ativado (Contact Shadows também).
2.  **Point Light (Rim Light / Backlight)**:
    *   Posicione ATRÁS e ACIMA do personagem, oposto à câmera.
    *   Power: Alto (ex: 500W - 1000W).
    *   Color: Branco ou levemente azulado/ciano para contraste.
    *   Radius: Grande para pegar mais borda.
3.  **Fill Light (Opcional)**:
    *   Luz de área suave vindo de baixo/frente para clarear as sombras se estiverem muito pretas (ou ajuste isso no ColorRamp do shader).

## 5. Câmera

*   **Type**: Orthographic.
*   **Orthographic Scale**: Ajuste para enquadrar (ex: 4 a 6 para unidades pequenas).
*   **Rotation**:
    *   X: 45° (ou 30° para visão mais de frente).
    *   Y: 45° (Isométrico real) ou 0° (Top-down simples).

---

## Resumo para Exportação

1.  Verifique se o fundo está transparente.
2.  Verifique se o Outline está com espessura constante.
3.  Rode o script de renderização (`render_sprites.py`).
