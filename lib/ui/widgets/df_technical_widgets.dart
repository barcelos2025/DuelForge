import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// Widget para renderizar imagens 9-slice (NinePatch)
/// 
/// Permite criar painéis escaláveis sem distorção de textura.
class NineSliceImage extends StatelessWidget {
  final String cornerAsset;
  final String edgeAsset;
  final String centerAsset;
  final double width;
  final double height;
  final double sliceSize;
  
  const NineSliceImage({
    super.key,
    required this.cornerAsset,
    required this.edgeAsset,
    required this.centerAsset,
    required this.width,
    required this.height,
    this.sliceSize = 32.0,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _NineSlicePainter(
          cornerAsset: cornerAsset,
          edgeAsset: edgeAsset,
          centerAsset: centerAsset,
          sliceSize: sliceSize,
        ),
      ),
    );
  }
}

class _NineSlicePainter extends CustomPainter {
  final String cornerAsset;
  final String edgeAsset;
  final String centerAsset;
  final double sliceSize;
  
  _NineSlicePainter({
    required this.cornerAsset,
    required this.edgeAsset,
    required this.centerAsset,
    required this.sliceSize,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: Implementar renderização 9-slice
    // Por enquanto, desenha um placeholder
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Widget para renderizar sprite sheets animados
class SpriteSheetAnimation extends StatefulWidget {
  final String spriteSheetAsset;
  final int frameCount;
  final int frameWidth;
  final int frameHeight;
  final Duration frameDuration;
  final bool loop;
  final VoidCallback? onComplete;
  
  const SpriteSheetAnimation({
    super.key,
    required this.spriteSheetAsset,
    required this.frameCount,
    required this.frameWidth,
    required this.frameHeight,
    required this.frameDuration,
    this.loop = true,
    this.onComplete,
  });
  
  @override
  State<SpriteSheetAnimation> createState() => _SpriteSheetAnimationState();
}

class _SpriteSheetAnimationState extends State<SpriteSheetAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  ui.Image? _spriteSheet;
  int _currentFrame = 0;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.frameDuration * widget.frameCount,
    );
    
    if (widget.loop) {
      _controller.repeat();
    } else {
      _controller.forward().then((_) => widget.onComplete?.call());
    }
    
    _controller.addListener(() {
      setState(() {
        _currentFrame = (_controller.value * widget.frameCount).floor() % widget.frameCount;
      });
    });
    
    _loadSpriteSheet();
  }
  
  Future<void> _loadSpriteSheet() async {
    // TODO: Carregar sprite sheet usando AssetBundle
    // Por enquanto, placeholder
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.frameWidth.toDouble(),
      height: widget.frameHeight.toDouble(),
      child: CustomPaint(
        painter: _SpriteSheetPainter(
          spriteSheet: _spriteSheet,
          currentFrame: _currentFrame,
          frameWidth: widget.frameWidth,
          frameHeight: widget.frameHeight,
          frameCount: widget.frameCount,
        ),
      ),
    );
  }
}

class _SpriteSheetPainter extends CustomPainter {
  final ui.Image? spriteSheet;
  final int currentFrame;
  final int frameWidth;
  final int frameHeight;
  final int frameCount;
  
  _SpriteSheetPainter({
    required this.spriteSheet,
    required this.currentFrame,
    required this.frameWidth,
    required this.frameHeight,
    required this.frameCount,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (spriteSheet == null) return;
    
    // Calcular posição do frame no sprite sheet
    final framesPerRow = spriteSheet!.width ~/ frameWidth;
    final row = currentFrame ~/ framesPerRow;
    final col = currentFrame % framesPerRow;
    
    final srcRect = Rect.fromLTWH(
      (col * frameWidth).toDouble(),
      (row * frameHeight).toDouble(),
      frameWidth.toDouble(),
      frameHeight.toDouble(),
    );
    
    final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    canvas.drawImageRect(spriteSheet!, srcRect, dstRect, Paint());
  }
  
  @override
  bool shouldRepaint(covariant _SpriteSheetPainter oldDelegate) {
    return oldDelegate.currentFrame != currentFrame;
  }
}

/// Helper para criar botões com estados usando assets
class DFAssetButton extends StatefulWidget {
  final String normalAsset;
  final String pressedAsset;
  final String? disabledAsset;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final Widget? child;
  
  const DFAssetButton({
    super.key,
    required this.normalAsset,
    required this.pressedAsset,
    this.disabledAsset,
    this.onPressed,
    this.width,
    this.height,
    this.child,
  });
  
  @override
  State<DFAssetButton> createState() => _DFAssetButtonState();
}

class _DFAssetButtonState extends State<DFAssetButton> {
  bool _isPressed = false;
  
  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;
    String currentAsset;
    
    if (!isEnabled && widget.disabledAsset != null) {
      currentAsset = widget.disabledAsset!;
    } else if (_isPressed) {
      currentAsset = widget.pressedAsset;
    } else {
      currentAsset = widget.normalAsset;
    }
    
    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      } : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              currentAsset,
              width: widget.width,
              height: widget.height,
              fit: BoxFit.contain,
            ),
            if (widget.child != null) widget.child!,
          ],
        ),
      ),
    );
  }
}
