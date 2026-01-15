import 'dart:ui';
import 'package:flame/components.dart';
import '../assets/asset_registry.dart';

class VfxComponent extends SpriteAnimationComponent {
  String vfxId = '';
  String animName = 'play';
  bool loopAnim = false;
  PositionComponent? followTarget;
  Vector2? offset;

  VfxComponent() : super(anchor: Anchor.center);

  /// Re-initializes the component for pooling
  void init({
    required String vfxId,
    required Vector2 position,
    Vector2? size,
    double angle = 0,
    int priority = 0,
    String animName = 'play',
    bool loop = false,
    PositionComponent? followTarget,
    Vector2? offset,
    BlendMode? blendMode,
  }) {
    this.vfxId = vfxId;
    this.position = position;
    this.size = size ?? Vector2.all(64);
    this.angle = angle;
    this.priority = priority;
    this.animName = animName;
    this.loopAnim = loop;
    this.followTarget = followTarget;
    this.offset = offset;
    
    if (blendMode != null) {
      paint.blendMode = blendMode;
    } else {
      paint.blendMode = BlendMode.srcOver; // Reset to default
    }
    
    // Reset state
    animation = null; // Will be loaded in onLoad or update
    _loadAnimation();
  }

  Future<void> _loadAnimation() async {
    // We assume 'idle' or the passed animName, and 'se' or 'no_dir'
    animation = await AssetRegistry().getAnimation(
      unitId: vfxId,
      anim: animName,
      dir: 'se', 
    );

    animation?.loop = loopAnim;
    animationTicker?.reset();
    
    if (!loopAnim) {
      animationTicker?.onComplete = () {
        removeFromParent();
        // In a real pool, we would return to pool here, but Flame's component lifecycle 
        // makes it easier to just remove and let the Manager handle the "pool" list 
        // or have the manager explicitly manage lifecycle.
        // For this implementation, we'll let the Manager handle the "return to pool" 
        // if we were using a custom component pool, but Flame doesn't have a built-in 
        // generic component pool that auto-recycles on remove.
        // We will implement the pool in VfxManager.
      };
    }
  }

  @override
  void onRemove() {
    super.onRemove();
    // Optional: clear references to help GC if not pooled immediately
    followTarget = null;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (animation == null && vfxId.isNotEmpty) {
      await _loadAnimation();
    }
  }
}
