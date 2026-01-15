import 'dart:convert';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart'; // Added
import 'package:flutter/services.dart';

class LoadedAnimation {
  final SpriteAnimation animation;
  final int hitFrame;
  final Vector2 pivot;

  LoadedAnimation({
    required this.animation,
    this.hitFrame = -1,
    required this.pivot,
  });
}

/// Handles loading of specific animation assets (PNG + JSON).
class AnimationLoader {
  static const String _basePath = 'assets/images/units';

  /// Loads a specific animation for a unit.
  /// 
  /// Expects files to be named:
  /// - PNG: assets/images/units/<unitId>/<unitId>_<anim>_<dir>.png
  /// - JSON: assets/images/units/<unitId>/<unitId>_<anim>_<dir>.json
  Future<LoadedAnimation?> loadUnitAnimation(
    String unitId,
    String anim,
    String dir,
  ) async {
    final fileName = '${unitId}_${anim}_${dir}';
    final path = 'units/$unitId/$fileName'; // Relative to assets/images/ for Flame

    try {
      // 1. Load JSON Metadata
      // Note: rootBundle paths must include 'assets/' prefix if defined that way in pubspec
      // Flame.images.load uses 'assets/images/' by default, but rootBundle needs full path.
      final jsonPath = 'assets/images/$path.json';
      final jsonString = await rootBundle.loadString(jsonPath);
      final jsonData = json.decode(jsonString);

      // 2. Parse Metadata
      final frameWidth = jsonData['frameWidth'] as int;
      final frameHeight = jsonData['frameHeight'] as int;
      final frameCount = jsonData['frameCount'] as int;
      final fps = (jsonData['fps'] as num).toDouble();
      final stepTime = 1.0 / fps;
      
      final pivotData = jsonData['pivot'];
      final pivot = Vector2(
        (pivotData['x'] as num).toDouble(),
        (pivotData['y'] as num).toDouble(),
      );
      
      final hitFrame = jsonData['hitFrame'] as int? ?? -1;

      // 3. Load Image Texture
      final image = await Flame.images.load('$path.png');

      // 4. Create SpriteAnimation
      final columns = jsonData['columns'] as int;
      // final rows = jsonData['rows'] as int; // Not strictly needed if we iterate by count

      final spriteSheet = SpriteSheet(
        image: image,
        srcSize: Vector2(frameWidth.toDouble(), frameHeight.toDouble()),
      );

      final sprites = <Sprite>[];
      for (int i = 0; i < frameCount; i++) {
        final row = i ~/ columns;
        final col = i % columns;
        sprites.add(spriteSheet.getSprite(row, col));
      }

      final animation = SpriteAnimation.spriteList(
        sprites,
        stepTime: stepTime,
        loop: anim != 'death',
      );
      
      return LoadedAnimation(
        animation: animation,
        hitFrame: hitFrame,
        pivot: pivot,
      );
    } catch (e) {
      print('Error loading animation $unitId/$anim/$dir: $e');
      return null;
    }
  }
}
