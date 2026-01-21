import 'package:flutter/material.dart';

class GlowBorder extends StatefulWidget {
  final Widget child;
  final bool isSelected;
  final Color color;

  const GlowBorder({
    super.key,
    required this.child,
    this.isSelected = false,
    this.color = Colors.cyanAccent,
  });

  @override
  State<GlowBorder> createState() => _GlowBorderState();
}

class _GlowBorderState extends State<GlowBorder> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Faster pulse
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isSelected) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          foregroundPainter: _GlowPainter(
            color: widget.color,
            progress: _controller.value,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _GlowPainter extends CustomPainter {
  final Color color;
  final double progress;

  _GlowPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Smaller, brighter, more pulsing glow in rarity color
    final glowPaint = Paint()
      ..color = color.withOpacity(0.6 + (progress * 0.35)) // Pulse 0.6 -> 0.95 (brighter)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 // Smaller
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5); // Tighter blur

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
      
    canvas.drawRRect(rrect, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _GlowPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
