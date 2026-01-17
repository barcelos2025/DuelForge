
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';

class ArenaBackgroundComponent extends PositionComponent with HasGameRef {
  final String assetPath;
  Sprite? _sprite;

  ArenaBackgroundComponent({required this.assetPath}) {
    priority = -100; // Ensure it's behind everything
  }

  @override
  Future<void> onLoad() async {
    // Load sprite. Note: assetPath should be relative to 'assets/images/' if Flame.images.prefix is set.
    // However, our assetPath is full 'assets/arenas/...'.
    // If Flame.images.prefix is 'assets/', then we need to strip 'assets/'.
    
    String cleanPath = assetPath;
    if (cleanPath.startsWith('assets/')) {
      cleanPath = cleanPath.substring(7); // Remove 'assets/'
    }
    
    debugPrint('ArenaBackgroundComponent: Loading background from $cleanPath (original: $assetPath)');
    
    try {
      _sprite = await gameRef.loadSprite(cleanPath);
      debugPrint('ArenaBackgroundComponent: Successfully loaded sprite. Size: ${_sprite!.srcSize}');
    } catch (e) {
      debugPrint('ArenaBackgroundComponent: Failed to load arena background: $assetPath. Error: $e');
    }
    
    _updateSize();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _updateSize();
  }

  void _updateSize() {
    // If sprite is null, we can still set size to screen size to draw fallback
    final screenW = gameRef.size.x;
    final screenH = gameRef.size.y;
    
    if (screenW == 0 || screenH == 0) return;

    if (_sprite != null) {
      // Cover logic
      final imgW = _sprite!.srcSize.x;
      final imgH = _sprite!.srcSize.y;

      final scale = max(screenW / imgW, screenH / imgH);
      
      final scaledW = imgW * scale;
      final scaledH = imgH * scale;

      // Center the image
      position = Vector2(
        (screenW - scaledW) / 2,
        (screenH - scaledH) / 2,
      );
      
      size = Vector2(scaledW, scaledH);
    } else {
      // Fallback size
      size = Vector2(screenW, screenH);
      position = Vector2.zero();
    }
  }

  @override
  void render(Canvas canvas) {
    if (_sprite != null) {
      _sprite!.render(canvas, position: Vector2.zero(), size: size);
    } else {
      // Fallback render if image missing
      canvas.drawRect(
        size.toRect(), 
        Paint()..color = const Color(0xFF13243A) // Surface color
      );
    }
  }
}
