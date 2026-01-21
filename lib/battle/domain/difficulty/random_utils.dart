import 'dart:math';

class RandomUtils {
  static final Random _rng = Random();

  /// Interpolação Linear
  static double lerp(double a, double b, double t) {
    return a + (b - a) * t.clamp(0.0, 1.0);
  }

  /// SmoothStep (Hermite interpolation)
  /// Retorna 0.0 se x <= edge0
  /// Retorna 1.0 se x >= edge1
  /// Retorna valor suave entre 0 e 1 se edge0 < x < edge1
  static double smoothStep(double edge0, double edge1, double x) {
    double t = ((x - edge0) / (edge1 - edge0)).clamp(0.0, 1.0);
    return t * t * (3.0 - 2.0 * t);
  }

  /// Distribuição Triangular Centrada em 0
  /// [amplitude] define o intervalo [-amplitude, +amplitude]
  /// Usa a soma de dois uniformes para aproximar (ou método clássico)
  static double triangular(double amplitude, {int? seed}) {
    final r = seed != null ? Random(seed) : _rng;
    // Soma de dois uniformes menos 1 gera uma distribuição triangular centrada em 0 (-1 a 1)
    // Multiplicamos pela amplitude.
    return (r.nextDouble() - r.nextDouble()) * amplitude;
  }

  /// Gera um seed determinístico baseado em strings e timestamp
  static int generateSeed(String userId, String matchId) {
    // Simples hash combination
    return (userId.hashCode ^ matchId.hashCode ^ DateTime.now().millisecondsSinceEpoch).abs();
  }
}
