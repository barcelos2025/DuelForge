import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class RewardVfxFlameComponent extends PositionComponent with HasGameRef {
  final Random _rnd = Random();

  @override
  Future<void> onLoad() async {
    // Explosão inicial de partículas
    _spawnExplosion();
  }

  void reset() {
    // Limpa partículas antigas e cria novas
    removeAll(children);
    _spawnExplosion();
  }

  void _spawnExplosion() {
    // Centro da tela (assumindo que o componente está centralizado ou ocupa tudo)
    // O GameWidget geralmente ocupa o container pai.
    // Vamos emitir do centro.
    final center = gameRef.size / 2;

    // Partículas "Rúnicas" (Quadrados girando)
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 30,
          lifespan: 1.5,
          generator: (i) {
            final angle = _rnd.nextDouble() * 2 * pi;
            final speed = _rnd.nextDouble() * 100 + 50;
            final velocity = Vector2(cos(angle), sin(angle)) * speed;
            
            return AcceleratedParticle(
              position: center,
              speed: velocity,
              acceleration: Vector2(0, 100), // Gravidade leve
              child: RotatingParticle(
                from: _rnd.nextDouble() * pi,
                to: _rnd.nextDouble() * pi,
                child: ComputedParticle(
                  renderer: (canvas, particle) {
                    final paint = Paint()
                      ..color = Colors.cyanAccent.withOpacity(1.0 - particle.progress);
                    // Desenha um losango/runa simples
                    canvas.drawRect(
                      Rect.fromCenter(center: Offset.zero, width: 8, height: 8), 
                      paint,
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );

    // Brilho central (Círculo expandindo)
    add(
      ParticleSystemComponent(
        particle: ComputedParticle(
          lifespan: 0.8,
          renderer: (canvas, particle) {
            final paint = Paint()
              ..color = Colors.white.withOpacity((1 - particle.progress) * 0.5)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2;
            
            canvas.drawCircle(
              center.toOffset(), 
              particle.progress * 200, // Expande até 200px
              paint,
            );
          },
        ),
      ),
    );
  }
}
