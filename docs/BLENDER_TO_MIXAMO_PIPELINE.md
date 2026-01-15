# Pipeline Blender -> Mixamo -> Blender (DuelForge)

Este documento detalha o fluxo de trabalho para criar, riggar e animar personagens usando o Mixamo e prepará-los para renderização de sprites no Blender.

## Fase 1: Preparação do Modelo (Blender)

Antes de exportar, o modelo deve estar limpo para garantir que o Auto-Rigger do Mixamo funcione corretamente.

1.  **Geometria**:
    *   **Unificar Malha**: Se possível, junte as partes do corpo (`Ctrl+J`) em um único objeto. Acessórios (espadas, escudos) podem ser separados, mas para o *auto-rig* é melhor que o corpo seja uma malha contínua.
    *   **T-Pose ou A-Pose**: O personagem deve estar em pose neutra, braços esticados, pernas levemente separadas.
    *   **Remover Rig Antigo**: Se já houver um esqueleto (Armature), delete-o e remova o modificador *Armature* da malha.

2.  **Transformações (CRUCIAL)**:
    *   Selecione o objeto.
    *   Pressione `Ctrl+A` > **All Transforms**.
    *   Verifique no painel 'N' (Item):
        *   Location: 0, 0, 0
        *   Rotation: 0, 0, 0
        *   Scale: 1, 1, 1

3.  **Orientação e Origem**:
    *   O personagem deve estar de frente para o **Eixo Y Negativo (-Y)** ou **Y Positivo (+Y)** (Mixamo geralmente prefere frente para Y+).
    *   A origem (ponto laranja) deve estar **entre os pés** (no chão, Z=0).

## Fase 2: Exportação FBX para Mixamo

Configurações exatas para evitar erros de "modelo deitado" ou escala errada.

1.  Vá em **File > Export > FBX (.fbx)**.
2.  No painel de configurações (lado direito):
    *   **Include**:
        *   Limit to: [x] Selected Objects (Selecione apenas a malha).
        *   Object Types: Mesh.
    *   **Transform**:
        *   Scale: `1.00`.
        *   Apply Scalings: **FBX All** (Importante para evitar problemas de escala).
        *   Forward: **-Z Forward** (Muitas vezes o padrão do Blender funciona, mas se falhar, tente Y Forward).
        *   Up: **Y Up**.
    *   **Geometry**:
        *   Smoothing: **Face** ou **Normals Only**.
    *   **Armature**: Desmarque (pois estamos enviando sem rig).
    *   **Bake Animation**: Desmarque.

## Fase 3: Mixamo (Auto-Rig e Animações)

1.  **Upload**:
    *   Faça login no Mixamo.
    *   Clique em **Upload Character** e arraste o FBX.
    *   Verifique se ele está em pé e de frente.

2.  **Auto-Rigger**:
    *   Posicione os marcadores (Chin, Wrists, Elbows, Knees, Groin) conforme indicado.
    *   **Skeleton LOD**: Use "Standard Skeleton" (65 bones) para ter dedos animados. Se for um minion muito pequeno, "No Fingers" (25 bones) economiza performance, mas perde expressividade.

3.  **Baixando o Modelo Base (T-Pose)**:
    *   Assim que o rig terminar, **NÃO** aplique animação ainda.
    *   Clique em **Download**.
    *   Format: **FBX Binary (.fbx)**.
    *   Skin: **With Skin**.
    *   Salve como `nome_personagem_TPOSE.fbx`.

4.  **Selecionando e Baixando Animações**:
    *   Busque e aplique as animações desejadas.
    *   **Configurações Importantes**:
        *   **In Place**: [x] MARQUE ISSO para *Walk* e *Run*. Para *Attack* e *Idle*, geralmente não é necessário, mas verifique se o personagem não sai do centro.
        *   **Character Arm-Space**: Aumente se os braços estiverem atravessando o corpo (clipping).
    *   **Download de cada animação**:
        *   Format: **FBX Binary**.
        *   Skin: **Without Skin** (Já temos a skin no T-Pose, isso economiza tamanho e evita duplicatas de malha).
        *   Frames per Second: **30** ou **60** (Reduziremos no Blender, melhor baixar com qualidade).
        *   Keyframe Reduction: **None** (Uniform).
    *   Salve como `anim_nome.fbx` (ex: `walk.fbx`, `attack.fbx`).

## Fase 4: Importação e Organização no Blender

O objetivo é ter um único arquivo `.blend` com o personagem e todas as animações como "Actions" na NLA.

1.  **Importar o Personagem Base**:
    *   Abra o seu `blender_template_duelforge.blend`.
    *   Importe o `nome_personagem_TPOSE.fbx`.
    *   Ajuste os materiais (reaplique o Material Toon e o Outline).

2.  **Importar Animações**:
    *   Importe um arquivo de animação (ex: `walk.fbx`).
    *   Isso criará um *novo* esqueleto com a animação.
    *   Selecione o esqueleto *novo*, vá no **Dope Sheet** > **Action Editor**.
    *   Copie o nome da Action (ex: `mixamo.com`).
    *   Selecione o esqueleto *original* (do T-Pose).
    *   No Action Editor, selecione a action que você acabou de importar.
    *   **Renomeie** a action para algo útil (ex: `ShieldWarrior_Walk`).
    *   Clique no botão **Push Down** (ícone de duas setas para baixo) ou **Stash**. Isso move a action para a **NLA Track** e libera o editor para a próxima.
    *   Delete o esqueleto *novo* (que veio com o `walk.fbx`), pois a animação já está salva no esqueleto original.
    *   Repita para todas as animações.

3.  **Ajuste de FPS e Duração**:
    *   No **NLA Editor**, você verá faixas para cada animação.
    *   Para renderizar sprites, precisamos ajustar o timing.
    *   Se o jogo pede 12 FPS para Walk:
        *   Nas configurações de Render (Output), setar **Frame Rate: 12**.
        *   No NLA, ajuste a **Scale** da strip de animação se ela ficar muito rápida ou lenta.
        *   Defina o **Start Frame** e **End Frame** na timeline para cobrir exatamente um loop (para Walk/Idle) ou a ação completa (Attack).

## Fase 5: Padronização e Solução de Problemas

### Manter o "Skeleton Padrão"
Se você tiver vários personagens humanoides com proporções similares:
1.  Use o mesmo esqueleto base renomeado (ex: `Humanoid_Rig`).
2.  Ao importar animações do Mixamo, se a estrutura óssea for idêntica (nomes dos ossos), as actions funcionarão em qualquer personagem.
3.  Se as proporções forem muito diferentes (ex: um anão vs um gigante), o Mixamo gera esqueletos diferentes. Nesse caso, é melhor tratar como rigs separados.

### Problemas Comuns e Soluções

| Problema | Causa Provável | Solução |
| :--- | :--- | :--- |
| **Pés deslizando (Moonwalk)** | Animação não está em loop perfeito ou velocidade do sprite no jogo difere da animação. | No Mixamo, use "In Place". No Blender, ajuste o *End Frame* para cortar exatamente onde o ciclo reinicia. |
| **Malha deformada/torta** | Escala ou Rotação não aplicada antes do export. | No Blender: `Ctrl+A` > All Transforms antes de exportar o FBX base. |
| **Mãos/Armas atravessando corpo** | Skinning automático imperfeito ou animação genérica. | No Mixamo, aumente "Character Arm-Space". No Blender, use *Graph Editor* para ajustar a rotação dos ossos do braço manualmente na Action (Layer de correção). |
| **Personagem flutuando** | Origem do objeto errada. | Certifique-se de que a origem (ponto laranja) está em Z=0 (entre os pés) antes de exportar. |
| **Texturas sumiram** | FBX não incorpora texturas complexas. | Reconfigure o material no Blender usando o Node Wrangler (`Ctrl+Shift+T`) ou configure o Material Toon manualmente. |
| **Muitos esqueletos na cena** | Importação de FBX cria novos rigs. | Sempre delete o rig importado APÓS transferir a Action para o rig principal. |

## Checklist de Entrega (Por Personagem)

- [ ] Personagem importado no Blender com materiais Toon e Outline configurados.
- [ ] Todas as Actions nomeadas corretamente (`UnitId_Anim`, ex: `thor_attack`).
- [ ] Actions organizadas na NLA (desmarcadas/mutadas, ativando uma por vez para render).
- [ ] FPS de render configurado (12, 15 ou 10).
- [ ] Câmera isométrica enquadrada.
- [ ] Teste de render de 1 frame para validar iluminação e recorte.
