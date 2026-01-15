# DuelForge VFX Specifications & Prompts

Este documento define as especificações e prompts para gerar os efeitos visuais (VFX) do jogo. Estes assets podem ser gerados via ferramentas de IA (como Midjourney/DALL-E 3) ou renderizados em softwares 3D/2D (Blender/After Effects).

## Especificações Gerais

- **Formato**: Spritesheet PNG (Grid) ou Sequência de PNGs.
- **Fundo**: Transparente (Alpha Channel).
- **Resolução por Frame**: 512x512 pixels.
- **Duração**: 16 a 24 frames.
- **FPS**: 15 FPS (Duração total aprox. 1.0 a 1.5 segundos).
- **Estilo**: Cartoon/Stylized, cores vibrantes, bordas definidas (opcional), alto contraste.
- **Perspectiva**: Top-down (visto de cima) ou levemente inclinado (45º) para combinar com o jogo.

---

## 1. Lightning Cloud (Relâmpago)
*Dano em área instantâneo com atordoamento.*

*   **Conceito**: Um raio cai do céu atingindo o chão, criando uma explosão elétrica e um anel de choque que se expande.
*   **Elementos**: Raio principal (branco/azul), faíscas voando, anel de energia no chão, brilho residual.
*   **Prompt Sugerido (AI)**:
    > Sprite sheet of a stylized cartoon lightning strike effect, top-down view game asset. Sequence showing a bright blue thunderbolt hitting the center, creating an electric explosion, flying sparks, and a glowing shockwave ring expanding on the ground. Transparent background, vibrant colors, cel shaded style, high contrast energy.
*   **Nome do Arquivo**: `vfx_lightning_cloud.png` (Atlas) ou `vfx_lightning_cloud.json`

## 2. Hailstorm (Tempestade de Gelo)
*Dano em área contínuo + Slow.*

*   **Conceito**: Uma área circular onde pedaços de gelo caem e quebram, com uma névoa fria no chão.
*   **Elementos**: Cristais de gelo caindo, impactos brancos/azuis, anel de geada no chão, névoa azulada.
*   **Prompt Sugerido (AI)**:
    > Sprite sheet of a stylized cartoon blizzard spell effect, top-down view game asset. Sequence showing ice shards falling and shattering on the ground, creating a circular area of frost mist and cold blue sparkles. Transparent background, magical ice VFX, mobile game style.
*   **Nome do Arquivo**: `vfx_hailstorm.png`

## 3. Poison (Veneno)
*Dano em área contínuo (DoT).*

*   **Conceito**: Uma poça borbulhante de ácido/veneno que emite vapores tóxicos.
*   **Elementos**: Líquido verde no chão, bolhas estourando, fumaça/caveiras pequenas subindo.
*   **Prompt Sugerido (AI)**:
    > Sprite sheet of a stylized cartoon poison cloud effect, top-down view game asset. Sequence showing a bubbling green acid pool on the ground emitting toxic fumes and small skull-shaped smoke. Transparent background, vibrant toxic green, cel shaded VFX.
*   **Nome do Arquivo**: `vfx_poison.png`

## 4. Voodoo Doll (Maldição)
*Debuff de dano recebido.*

*   **Conceito**: Uma aura sinistra e mágica que envolve a área ou alvo.
*   **Elementos**: Runas roxas/escuras flutuando, aura pulsante, agulhas fantasmas ou boneco voodoo translúcido aparecendo brevemente.
*   **Prompt Sugerido (AI)**:
    > Sprite sheet of a stylized cartoon dark magic curse effect, top-down view game asset. Sequence showing a purple aura with floating glowing runes and shadow energy pulsing around a center point. Transparent background, mystical, witchcraft style.
*   **Nome do Arquivo**: `vfx_voodoo.png`

## 5. Thunder Hammer (Impacto Único)
*Dano massivo em área pequena.*

*   **Conceito**: Um impacto físico devastador que gera uma onda de choque e luz, sem destruir o cenário permanentemente.
*   **Elementos**: Martelo (opcional, ou apenas o impacto), flash de luz amarela/laranja, rachaduras luminosas que aparecem e somem, poeira sendo levantada.
*   **Prompt Sugerido (AI)**:
    > Sprite sheet of a stylized cartoon heavy smash impact effect, top-down view game asset. Sequence showing a powerful ground slam creating a burst of golden light, temporary glowing cracks on the floor, and a dust shockwave. Transparent background, impact VFX, dynamic action.
*   **Nome do Arquivo**: `vfx_thunder_hammer.png`

## 6. Runic Spear Rain (Chuva de Projéteis)
*Dano em área múltiplo.*

*   **Conceito**: Várias lanças mágicas caindo do céu em uma área circular.
*   **Elementos**: Lanças douradas/brilhantes caindo aleatoriamente na área, pequenos impactos circulares onde elas tocam o chão.
*   **Prompt Sugerido (AI)**:
    > Sprite sheet of a stylized cartoon magic arrow rain effect, top-down view game asset. Sequence showing multiple glowing golden spears falling from above into a circular area, creating small impact flashes on the ground. Transparent background, divine magic style.
*   **Nome do Arquivo**: `vfx_spear_rain.png`

---

## Integração no Flutter + Flame

### 1. Estrutura de Arquivos
Coloque os spritesheets em:
`assets/images/vfx/<nome_do_arquivo>.png`
Se usar JSON (TexturePacker), coloque junto:
`assets/images/vfx/<nome_do_arquivo>.json`

### 2. Carregamento (Exemplo de Código)

```dart
import 'package:flame/components.dart';

class VfxComponent extends SpriteAnimationComponent with HasGameRef {
  final String vfxName;
  final bool loop;
  final VoidCallback? onFinish;

  VfxComponent({
    required this.vfxName,
    required Vector2 position,
    Vector2? size,
    this.loop = false,
    this.onFinish,
  }) : super(
          position: position,
          size: size ?? Vector2(3, 3), // Tamanho em unidades do jogo (ex: 3 tiles)
          anchor: Anchor.center,
          removeOnFinish: !loop,
        );

  @override
  Future<void> onLoad() async {
    // Opção A: Carregar de Spritesheet Grid (ex: 4x4 frames)
    // Assumindo imagem 2048x2048 com frames de 512x512 -> 4 colunas, 4 linhas = 16 frames
    final spriteSheet = await gameRef.images.load('vfx/$vfxName.png');
    animation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 16, // Ajuste conforme o asset
        stepTime: 1.0 / 15.0, // 15 FPS
        textureSize: Vector2.all(512),
        loop: loop,
      ),
    );
    
    // Opção B: Carregar de JSON (TexturePacker)
    // final spriteSheet = await gameRef.images.load('vfx/$vfxName.png');
    // final atlas = await gameRef.assets.loadJson('vfx/$vfxName.json');
    // animation = SpriteAnimation.fromAsepriteData(spriteSheet, atlas);

    if (onFinish != null) {
      animationTicker?.onComplete = onFinish;
    }
  }
}
```

### 3. Uso no Jogo

Quando um feitiço for ativado ou um projétil explodir:

```dart
// Exemplo: Spawnar efeito de raio
game.world.add(VfxComponent(
  vfxName: 'vfx_lightning_cloud',
  position: targetPosition,
  size: Vector2(4, 4), // Área de 4 metros
  loop: false,
));
```
