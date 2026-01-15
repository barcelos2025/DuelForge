import 'dart:async';
import 'dart:ui' as ui;
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/foundation.dart';
import 'animation_loader.dart';

/// Central registry for managing game assets (sprites, animations).
/// Handles caching, preloading, and fallback logic.
class AssetRegistry {
  static final AssetRegistry _instance = AssetRegistry._internal();
  
  factory AssetRegistry() {
    return _instance;
  }

  AssetRegistry._internal();

  final AnimationLoader _loader = AnimationLoader();
  final Map<String, LoadedAnimation> _cache = {};
  
  LoadedAnimation? _placeholderAnimation;

  /// Returns a unique key for the cache.
  String _getKey(String unitId, String anim, String dir) {
    return '${unitId}_${anim}_${dir}';
  }

  /// Retrieves an animation. 
  /// If cached, returns immediately.
  /// If not, tries to load it. 
  /// If loading fails, returns a placeholder.
  Future<LoadedAnimation> getAnimation({
    required String unitId,
    required String anim,
    required String dir,
  }) async {
    final key = _getKey(unitId, anim, dir);

    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    // Attempt to load
    final loadedAnim = await _loader.loadUnitAnimation(unitId, anim, dir);

    if (loadedAnim != null) {
      _cache[key] = loadedAnim;
      return loadedAnim;
    } else {
      debugPrint('[AssetRegistry] MISSING ASSET: $unitId $anim $dir. Using placeholder.');
      return await _getPlaceholder();
    }
  }

  /// Preloads a list of assets to avoid runtime stutter.
  /// Returns a Future that completes when all are loaded (or failed and fell back).
  Future<void> preloadAssets(List<({String unitId, String anim, String dir})> assets) async {
    final futures = <Future>[];
    for (final asset in assets) {
      futures.add(getAnimation(
        unitId: asset.unitId,
        anim: asset.anim,
        dir: asset.dir,
      ));
    }
    await Future.wait(futures);
  }

  /// Generates or returns the singleton placeholder animation.
  Future<LoadedAnimation> _getPlaceholder() async {
    if (_placeholderAnimation != null) return _placeholderAnimation!;

    // Create a 32x32 magenta square texture for missing assets
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final paint = ui.Paint()..color = const ui.Color(0xFFFF00FF); // Magenta
    canvas.drawRect(const ui.Rect.fromLTWH(0, 0, 32, 32), paint);
    final picture = recorder.endRecording();
    final image = await picture.toImage(32, 32);

    final sprite = Sprite(image);
    final animation = SpriteAnimation.spriteList(
      [sprite],
      stepTime: 1.0,
      loop: true,
    );

    _placeholderAnimation = LoadedAnimation(
      animation: animation,
      hitFrame: -1,
      pivot: Vector2(0.5, 0.5),
    );

    return _placeholderAnimation!;
  }

  /// Clears the cache to free memory.
  void clearCache() {
    _cache.clear();
    // We might want to keep the placeholder
  }
}
