import 'dart:math';
import 'package:flutter/material.dart';

class SnowEffect extends StatefulWidget {
  final int particleCount;
  final Color color;

  const SnowEffect({
    super.key, 
    this.particleCount = 40,
    this.color = Colors.white,
  });

  @override
  State<SnowEffect> createState() => _SnowEffectState();
}

class _SnowEffectState extends State<SnowEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_SnowParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(_generateParticle());
    }
  }

  _SnowParticle _generateParticle() {
    return _SnowParticle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      speed: _random.nextDouble() * 0.8 + 0.2,
      size: _random.nextDouble() * 2.5 + 1,
      opacity: _random.nextDouble() * 0.6 + 0.1,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _SnowPainter(
              particles: _particles,
              progress: _controller.value,
              color: widget.color,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _SnowParticle {
  double x;
  double y;
  double speed;
  double size;
  double opacity;

  _SnowParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
  });
}

class _SnowPainter extends CustomPainter {
  final List<_SnowParticle> particles;
  final double progress;
  final Color color;

  _SnowPainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var particle in particles) {
      // Move downwards continuously
      double effectiveY = (particle.y + progress * particle.speed * 10) % 1.0;
      
      // Slight horizontal sway
      double effectiveX = (particle.x + sin(progress * 2 * pi * particle.speed + particle.y * 10) * 0.05);
      
      // Wrap X
      if (effectiveX > 1.0) effectiveX -= 1.0;
      if (effectiveX < 0.0) effectiveX += 1.0;

      paint.color = color.withOpacity(particle.opacity);
      canvas.drawCircle(
        Offset(effectiveX * size.width, effectiveY * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
