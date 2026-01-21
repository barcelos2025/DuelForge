import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class AvatarSnowParticles extends StatelessWidget {
  const AvatarSnowParticles({super.key});

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: SnowGame(),
      backgroundBuilder: (context) => const SizedBox.shrink(),
    );
  }
}

class SnowGame extends FlameGame {
  final Random _rnd = Random();

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    // Spawn a new particle every 0.1 seconds
    add(
      TimerComponent(
        period: 0.1,
        repeat: true,
        onTick: () {
          // Add a batch of particles
          add(
            ParticleSystemComponent(
              particle: Particle.generate(
                count: 2,
                lifespan: 10,
                generator: (i) => AcceleratedParticle(
                  position: Vector2(
                    _rnd.nextDouble() * size.x,
                    -10,
                  ),
                  speed: Vector2(
                    _rnd.nextDouble() * 20 - 10, // Slight horizontal drift
                    _rnd.nextDouble() * 50 + 20, // Slow descent
                  ),
                  child: CircleParticle(
                    radius: _rnd.nextDouble() * 2 + 1, // Small flakes
                    paint: Paint()
                      ..color = Colors.white.withOpacity(_rnd.nextDouble() * 0.3 + 0.1) // Low opacity
                      ..style = PaintingStyle.fill,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
