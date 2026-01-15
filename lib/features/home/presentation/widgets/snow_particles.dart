import 'dart:math';
import 'package:flutter/material.dart';

class SnowParticles extends StatefulWidget {
  const SnowParticles({super.key});

  @override
  State<SnowParticles> createState() => _SnowParticlesState();
}

class _SnowParticlesState extends State<SnowParticles> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Generate initial particles
    for (int i = 0; i < 50; i++) {
      _particles.add(_generateParticle());
    }
  }

  _Particle _generateParticle() {
    return _Particle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      speed: _random.nextDouble() * 0.2 + 0.05,
      size: _random.nextDouble() * 2 + 1,
      opacity: _random.nextDouble() * 0.5 + 0.1,
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
          painter: _SnowPainter(_particles, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  double x;
  double y;
  double speed;
  double size;
  double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
  });
}

class _SnowPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _SnowPainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    for (var particle in particles) {
      // Update position (simple simulation inside paint for visual only)
      // Ideally logic should be separate, but for simple ambient effect this is fine
      // We use progress to drive continuous movement if we wanted deterministic, 
      // but here we just drift downwards.
      
      // Actually, to make it smooth with AnimationController repeat, we need to move them based on time.
      // Since we are in paint, let's just use the fact that paint is called every frame 
      // (due to AnimatedBuilder on controller).
      
      particle.y += particle.speed * 0.01; // Simple increment
      if (particle.y > 1.0) {
        particle.y = -0.1;
        particle.x = Random().nextDouble();
      }

      paint.color = Colors.white.withOpacity(particle.opacity);
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
