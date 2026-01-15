# Checklist de Consistência Visual "Fake AAA"

Este documento define os padrões rigorosos para manter a qualidade visual do DuelForge.

## 1. Escala Relativa (Blender)

Para garantir que um Goblin não fique maior que um Gigante na tela.
Use um cubo de referência de **1.8m** (Altura Humana) na cena.

| Categoria | Altura (Metros no Blender) | Exemplo |
| :--- | :--- | :--- |
| **Pequeno (Minions)** | 0.8m - 1.2m | Goblins, Esqueletos |
| **Médio (Humanos)** | 1.7m - 1.9m | Arqueiro, Cavaleiro |
| **Grande (Tanques)** | 2.5m - 3.0m | Orc, Golem de Pedra |
| **Gigante (Bosses)** | 4.0m+ | Dragão, Gigante Real |

*Nota*: No render final (PNG), o tamanho em pixels pode variar, mas a proporção visual deve ser mantida pelo **Orthographic Scale** da câmera, que deve ser **FIXO** em `4.0` (ou valor escolhido) para TODOS os renders. Se precisar de mais espaço no frame, aumente a resolução do canvas, não o zoom da câmera.

## 2. Outline (Borda)

O outline garante a leitura em telas pequenas de celular.

*   **Método**: Inverted Hull (Solidify Modifier).
*   **Espessura (Thickness)**:
    *   Unidades Pequenas/Médias: `-0.02m`
    *   Unidades Grandes: `-0.03m`
    *   Construções: `-0.025m`
*   **Cor**: Preto Puro (`#000000`) ou Azul Escuro Profundo (`#050510`) para suavizar.

## 3. Paleta de Cores por Facção

Use estas cores como *Accent* (detalhes, tecidos, magia) para identificar a origem da unidade.

*   **Neutro / Player**: Azul Real (`#2E86DE`)
*   **Inimigo**: Vermelho Sangue (`#EE5253`)
*   **Facção Gelo (Norte)**: Ciano (`#48DBFB`) + Branco Gelo
*   **Facção Fogo (Vulcão)**: Laranja Queimado (`#E15F41`) + Cinza Escuro
*   **Facção Runas (Mística)**: Roxo Neon (`#A55EEA`) + Dourado
*   **Facção Sombras (Undead)**: Verde Tóxico (`#1DD1A1`) + Preto

## 4. Iluminação (Setup Fixo)

NUNCA altere a luz para "ficar mais bonito" em uma unidade específica, pois quebrará a coesão no jogo.

*   **Key Light**: Sun, Strength 4.0, Cor `#FFF5E0` (Quente).
*   **Fill Light**: Area, Power 150W, Cor `#DCEEFF` (Frio).
*   **Rim Light**: Spot, Power 300W, Atrás do personagem.
*   **Shadows**: Contact Shadows ativadas no Eevee.

## 5. Pivô e Margens

*   **Pivô (Origin Point)**: SEMPRE entre os pés, no chão (Z=0).
    *   Isso garante que o pé da unidade esteja exatamente onde a lógica do jogo diz que ela está.
*   **Margens**:
    *   Deixe pelo menos **10% de respiro** nas bordas do frame para evitar cortar armas durante animações de ataque ou morte.
    *   Se a arma for muito longa (lança), é melhor diminuir a escala geral do sprite do que cortar a ponta.

## 6. Renderização (Toon Shading)

*   **Banding**: Use `Constant` interpolation no ColorRamp.
*   **Flicker**: Evite linhas muito finas na textura interna. O outline cuida da silhueta, mas detalhes internos (como fivelas de cinto) devem ser pintados na textura, não modelados, para evitar ruído visual (aliasing) ao reduzir.
*   **Anti-Aliasing**: Renderize com `Film: Transparent` e `Filter Size: 1.5px` (padrão Blender) para suavizar as bordas serrilhadas do pixel art fake.

## 7. Validação Final

Antes de commitar o asset:
1.  [ ] O pé está no centro horizontal do frame?
2.  [ ] A iluminação vem da esquerda (topo)?
3.  [ ] O outline está visível mas não grosso demais?
4.  [ ] As cores batem com a paleta da facção?
5.  [ ] A animação de `idle` e `walk` está em loop perfeito?
