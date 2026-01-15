import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class VfxComponent extends SpriteAnimationComponent with HasGameRef {
  final String vfxName;
  final bool loop;
  final VoidCallback? onFinish;
  final int amount;
  final double stepTime;

  VfxComponent({
    required this.vfxName,
    required Vector2 position,
    Vector2? size,
    this.loop = false,
    this.onFinish,
    this.amount = 16,
    this.stepTime = 0.066, // ~15 FPS
  }) : super(
          position: position,
          size: size ?? Vector2(3, 3),
          anchor: Anchor.center,
          removeOnFinish: !loop,
        );

  @override
  Future<void> onLoad() async {
    try {
      // Try loading as grid spritesheet first (standard for generated VFX)
      // Assuming 512x512 frames
      final spriteSheet = await gameRef.images.load('vfx/$vfxName.png');
      
      // Calculate columns based on image width
      final cols = (spriteSheet.width / 512).floor();
      
      animation = SpriteAnimation.fromFrameData(
        spriteSheet,
        SpriteAnimationData.sequenced(
          amount: amount,
          stepTime: stepTime,
          textureSize: Vector2.all(512),
          amountPerRow: cols,
          loop: loop,
        ),
      );

      if (onFinish != null) {
        animationTicker?.onComplete = onFinish;
      }
    } catch (e) {
      print('Failed to load VFX: $vfxName - $e');
      // Fallback: Simple circle flash
      // We can't easily draw shapes in SpriteAnimationComponent without a sprite.
      // So we just remove self to avoid stuck component.
      removeFromParent();
    }
  }
}
