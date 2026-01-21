import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'duelforge_vfx_config.dart';

/// Fábrica responsável por criar Componentes de VFX (Partículas e Efeitos).
/// Usa fallback procedural quando assets não estão disponíveis.
class DuelForgeVfxFactory {
  static final Random _rng = Random();

  // --- Utilitários ---
  
  static Vector2 _randomVector(double scale) {
    return Vector2((_rng.nextDouble() - 0.5) * scale, (_rng.nextDouble() - 0.5) * scale);
  }

  static Color _randomColorVariation(int baseColorHex, {int variation = 20}) {
    final color = Color(baseColorHex);
    return Color.fromARGB(
      color.alpha,
      (color.red + _rng.nextInt(variation * 2) - variation).clamp(0, 255),
      (color.green + _rng.nextInt(variation * 2) - variation).clamp(0, 255),
      (color.blue + _rng.nextInt(variation * 2) - variation).clamp(0, 255),
    );
  }

  // --- Efeitos de Impacto ---

  static ParticleSystemComponent criarImpactoFisico(Vector2 posicao) {
    return ParticleSystemComponent(
      position: posicao,
      particle: Particle.generate(
        count: 12,
        lifespan: 0.6,
        generator: (i) => AcceleratedParticle(
          acceleration: Vector2(0, 100), // Gravidade leve
          speed: _randomVector(150),
          child: CircleParticle(
            radius: 2 + _rng.nextDouble() * 2,
            paint: Paint()..color = _randomColorVariation(DuelForgeVfxConfig.corImpactoFisico),
          ),
        ),
      ),
    );
  }

  static ParticleSystemComponent criarImpactoMagico(Vector2 posicao) {
    return ParticleSystemComponent(
      position: posicao,
      particle: Particle.generate(
        count: 15,
        lifespan: 0.8,
        generator: (i) => ComputedParticle(
          renderer: (canvas, particle) {
            final paint = Paint()
              ..color = Color(DuelForgeVfxConfig.corMagiaRunica).withOpacity(1 - particle.progress)
              ..style = PaintingStyle.fill
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
            
            canvas.drawCircle(Offset.zero, (3 * (1 - particle.progress)), paint);
          },
        ),
      ),
    );
  }

  static ParticleSystemComponent criarHitFlash(Vector2 posicao) {
    return ParticleSystemComponent(
      position: posicao,
      particle: CircleParticle(
        radius: 15,
        lifespan: 0.1,
        paint: Paint()..color = Colors.white.withOpacity(0.8),
      ),
    );
  }

  // --- Efeitos Elementais ---

  static ParticleSystemComponent criarExplosaoFogo(Vector2 posicao) {
    return ParticleSystemComponent(
      position: posicao,
      particle: Particle.generate(
        count: 20,
        lifespan: 0.8,
        generator: (i) => AcceleratedParticle(
          speed: Vector2(_rng.nextDouble() * 100 - 50, -_rng.nextDouble() * 150), // Sobe
          child: CircleParticle(
            radius: 3 + _rng.nextDouble() * 3,
            paint: Paint()..color = _randomColorVariation(DuelForgeVfxConfig.corFogoBrsa).withOpacity(0.8),
          ),
        ),
      ),
    );
  }

  static ParticleSystemComponent criarExplosaoGelo(Vector2 posicao) {
    return ParticleSystemComponent(
      position: posicao,
      particle: Particle.generate(
        count: 15,
        lifespan: 0.7,
        generator: (i) => MovingParticle(
          to: _randomVector(100),
          child: ComputedParticle(
            renderer: (canvas, particle) {
              final paint = Paint()..color = Color(DuelForgeVfxConfig.corGelo).withOpacity(1 - particle.progress);
              // Desenha shard (triângulo simples)
              final path = Path()
                ..moveTo(0, -4)
                ..lineTo(3, 4)
                ..lineTo(-3, 4)
                ..close();
              canvas.drawPath(path, paint);
            },
          ),
        ),
      ),
    );
  }

  static ParticleSystemComponent criarNuvemVeneno(Vector2 posicao) {
    return ParticleSystemComponent(
      position: posicao,
      particle: Particle.generate(
        count: 30,
        lifespan: 2.0,
        generator: (i) => MovingParticle(
          curve: Curves.easeOut,
          to: Vector2(_rng.nextDouble() * 60 - 30, -20), // Sobe devagar
          child: CircleParticle(
            radius: 4 + _rng.nextDouble() * 6,
            paint: Paint()
              ..color = Color(DuelForgeVfxConfig.corVeneno).withOpacity(0.4)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
          ),
        ),
      ),
    );
  }

  static ParticleSystemComponent criarRaioImpacto(Vector2 posicao) {
    // Simula um raio caindo com linhas rápidas
    return ParticleSystemComponent(
      position: posicao,
      particle: Particle.generate(
        count: 5,
        lifespan: 0.2,
        generator: (i) => ComputedParticle(
          renderer: (canvas, particle) {
            final paint = Paint()
              ..color = Colors.cyanAccent.withOpacity(1 - particle.progress)
              ..strokeWidth = 2
              ..style = PaintingStyle.stroke;
            
            final offset = _randomVector(20);
            canvas.drawLine(Offset(0, -100), Offset(offset.x, offset.y), paint);
          },
        ),
      ),
    );
  }

  // --- Efeitos de Torre ---

  static ParticleSystemComponent criarDestruicaoTorre(Vector2 posicao) {
    // Poeira pesada e detritos
    return ParticleSystemComponent(
      position: posicao,
      particle: Particle.generate(
        count: 40,
        lifespan: 1.5,
        generator: (i) => AcceleratedParticle(
          acceleration: Vector2(0, 200), // Gravidade forte
          speed: _randomVector(200),
          child: ComputedParticle(
            renderer: (canvas, particle) {
              final paint = Paint()..color = Colors.grey[800]!;
              canvas.drawRect(Rect.fromLTWH(0, 0, 6, 6), paint);
            },
          ),
        ),
      ),
    );
  }
}
