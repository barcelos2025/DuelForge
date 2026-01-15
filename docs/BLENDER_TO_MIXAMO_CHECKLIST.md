# Checklist: Preparação de Personagem Blender para Mixamo

Este guia garante que seu personagem seja rigado corretamente pelo Auto-Rigger do Mixamo e esteja otimizado para jogos mobile (DuelForge).

## 1. Geometria e Malha (Mesh)

- [ ] **T-Pose ou A-Pose**:
    - O personagem deve estar em pose neutra.
    - **T-Pose (Recomendado)**: Braços esticados horizontalmente, pernas retas e levemente separadas. Dedos separados.
    - *Por que?* Facilita para o algoritmo identificar juntas e evitar "colar" a malha (ex: axilas).
- [ ] **Malha Única (Single Mesh)**:
    - Junte todas as partes do corpo (cabeça, roupas, corpo) em um único objeto (`Ctrl + J`).
    - *Exceção*: Se tiver olhos/dentes separados, garanta que estão dentro da cabeça.
- [ ] **Topologia Limpa**:
    - Evite N-Gons (faces com mais de 4 lados). Use Quads ou Tris.
    - Remova vértices duplos (`M > By Distance`).
    - Recalcule as Normais (`Shift + N`) para garantir que estão viradas para fora.
- [ ] **Sem Acessórios Complexos**:
    - Remova ou separe armas, escudos e capas complexas antes de enviar.
    - *Dica*: Riggue o corpo no Mixamo. Adicione armas depois no Blender/Engine parentando ao osso da mão.
- [ ] **Contagem de Polígonos (Mobile)**:
    - **Tropas (Zoom distante)**: 1.500 - 3.000 triângulos.
    - **Heróis/Lendárias**: 3.000 - 5.000 triângulos.
    - *Nota*: Como usamos render para sprites, podemos ir um pouco mais alto (até 10k), mas manter leve ajuda no viewport e render time.

## 2. Transformações e Escala

- [ ] **Aplicar Transformações (Essencial)**:
    - Selecione o objeto e pressione `Ctrl + A` > **All Transforms**.
    - Escala deve ser `1.0, 1.0, 1.0`.
    - Rotação deve ser `0, 0, 0`.
    - Posição deve ser `0, 0, 0` (Pés no chão, origem entre os pés).
- [ ] **Orientação**:
    - O personagem deve estar de frente para a vista **Frontal** do Blender (Pressione `1` no Numpad).
    - No Blender, isso significa estar virado para **-Y**.
- [ ] **Dimensões Reais**:
    - Verifique se o personagem tem altura realista (ex: 1.8m para humano). O Mixamo pode falhar com personagens gigantes ou microscópicos.

## 3. Materiais e Texturas

- [ ] **Materiais Simples**:
    - O Mixamo não lê shaders complexos do Blender.
    - Use um material simples com a textura de cor (Diffuse) conectada se quiser visualizar no Mixamo.
    - *Dica*: Para o Auto-Rigger, a textura não importa, apenas a silhueta. Pode enviar sem textura (modelo cinza) para ser mais rápido.

## 4. Exportação FBX (Configurações)

Use estas configurações na janela de exportação do Blender (`File > Export > FBX`):

- [ ] **Include**:
    - Limit to: **Selected Objects** (Marque para não exportar lixo da cena).
    - Object Types: **Mesh** (apenas).
- [ ] **Transform**:
    - Scale: **1.00**.
    - Apply Scalings: **FBX All** (Ajuda a evitar bugs de escala).
    - Forward: **-Z Forward**.
    - Up: **Y Up**.
- [ ] **Geometry**:
    - Apply Modifiers: **Sim** (se tiver Mirror ou Subdivision não aplicados).
- [ ] **Armature**:
    - Desmarque "Add Leaf Bones" (Opcional, mas deixa o rig mais limpo se for trazer de volta pro Blender).
- [ ] **Bake Animation**: **Não** (Desmarque).

## 5. Erros Comuns e Soluções

| Erro | Causa Provável | Solução |
|------|----------------|---------|
| **"Unable to map existing skeleton"** | Você enviou um arquivo que já tem ossos/armature. | Delete a armature no Blender e envie **apenas a malha (Mesh)**. |
| **Personagem deitado ou voando** | Origem ou Rotação errada. | Aplique `Ctrl+A > All Transforms` e garanta que a origem (ponto laranja) está entre os pés (0,0,0). |
| **Dedos colados ou malha distorcida** | Dedos muito juntos ou normais invertidas. | Separe mais os dedos na T-Pose. Verifique a orientação das normais (`Shift+N`). |
| **Assimetria no Rig** | O personagem não está centralizado no eixo X. | Garanta que o centro do personagem está exatamente em X=0. |
| **Mixamo trava no upload** | Arquivo muito pesado ou texturas 4k/8k embutidas. | Reduza a contagem de polígonos. Exporte sem texturas (Path Mode: Auto, sem embed). |

## 6. Workflow Recomendado (DuelForge)

1.  Modele e Texturize no Blender.
2.  Salve uma cópia do arquivo (`_pre_mixamo.blend`).
3.  Junte as malhas, aplique transforms, remova armature existente.
4.  Exporte FBX (`char_mesh.fbx`).
5.  Upload no Mixamo -> Auto-Rigger -> Escolha animações.
6.  Download FBX (With Skin) para o T-Pose rigado.
7.  Download FBX (Without Skin) para as animações (Idle, Walk, Attack).
8.  Importe no Blender para renderizar os sprites (usando o script de pipeline).
