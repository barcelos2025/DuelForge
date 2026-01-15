import 'package:flame/components.dart';
import '../vfx/vfx_manager.dart';
import 'package:flame/game.dart';

class HitVfxLibrary {
  static VfxManager? _vfxManager;

  static void initialize(VfxManager manager) {
    _vfxManager = manager;
  }

  static void spawnHitSpark(Vector2 position) {
    if (_vfxManager == null) return;

    // We can use a generic 'hit_spark' vfx ID
    // Or just a quick placeholder animation
    _vfxManager!.spawnVfx(
      vfxId: 'vfx_hit_spark',
      position: position,
      scale: Vector2.all(0.5),
      layer: VfxManager.layerTop,
      loop: false,
    );
  }
}
