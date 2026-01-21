import 'dart:math';
import 'package:flutter/material.dart';

class SnowOverlay extends StatefulWidget {
  final int particleCount;
  final Color color;

  const SnowOverlay({
    super.key,
    this.particleCount = 50,
    this.color = Colors.white,
  });

  @override
  State<SnowOverlay> createState() => _SnowOverlayState();
}

class _SnowOverlayState extends State<SnowOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_SnowParticle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _particles = List.generate(widget.particleCount, (index) => _createParticle());
  }

  _SnowParticle _createParticle() {
    return _SnowParticle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      speed: _random.nextDouble() * 0.5 + 0.2,
      size: _random.nextDouble() * 3 + 1,
      opacity: _random.nextDouble() * 0.5 + 0.3,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
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
    );
  }
}

class _SnowParticle {
  double x;
  double y;
  final double speed;
  final double size;
  final double opacity;

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
    final paint = Paint()..color = color;

    for (var particle in particles) {
      // Update position based on speed (simulated by just moving it down)
      // We use a simplified simulation here where we just draw based on current state + small delta
      // Actually, for a smooth animation in CustomPainter without updating state explicitly, 
      // we can just increment Y. But since we are in AnimatedBuilder, we can update the particle state here 
      // or just use the controller value to shift them. 
      // To keep it simple and continuous, let's update the particle Y position.
      
      particle.y += particle.speed * 0.005; // Small increment per frame
      if (particle.y > 1.0) {
        particle.y = -0.1;
        particle.x = Random().nextDouble();
      }

      final dx = particle.x * size.width;
      final dy = particle.y * size.height;

      paint.color = color.withOpacity(particle.opacity);
      canvas.drawCircle(Offset(dx, dy), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
