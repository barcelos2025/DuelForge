import 'dart:math';
import 'ai_core.dart';
import 'policies/bot_basico_policy.dart';
import 'policies/bot_tatico_policy.dart';
import 'policies/bot_especialista_policy.dart';

class DificuldadeService {
  /// Calcula a dificuldade (0.0 a 1.0) baseada no perfil do jogador.
  static BotConfig calcularConfiguracao(int trofeus, double winRate, double nivelMedioCartas, int consecutiveLosses) {
    final rng = Random();

    // 1. Dificuldade Base (0.0 a 1.0)
    // Normalizar Arena (0 a 3000+)
    double normArena = (trofeus / 3000.0).clamp(0.0, 1.0);
    
    // Skill Estimado (WinRate como proxy)
    double skillEstimado = winRate.clamp(0.0, 1.0);
    
    // Tilt Assist (Ajuda se perder muito)
    double tiltAssist = 0.0;
    if (consecutiveLosses >= 2) {
      tiltAssist = (consecutiveLosses - 1) * 0.1;
      tiltAssist = tiltAssist.clamp(0.0, 0.4); // Max 40% help
    }

    // Pesos: Arena define o "chão", Skill ajusta, Tilt ajuda.
    double dBase = (0.6 * normArena) + (0.4 * skillEstimado) - tiltAssist;
    dBase = dBase.clamp(0.0, 1.0);

    // 2. Ruído Triangular Centrado
    // Amplitude diminui com a liga (mais caótico no início)
    double amplitude = 0.12 - (0.08 * normArena); // 0.12 -> 0.04
    // Triangular distribution approx centered at 0 (Sum of two uniforms - 1)
    double ruido = (rng.nextDouble() - rng.nextDouble()) * amplitude; 

    // 3. Ajuste de "Leve Tendência a Vitória"
    // Para iniciantes, reduzimos a dificuldade base para garantir onboarding suave
    if (normArena < 0.2) {
      dBase -= 0.10; 
    } else if (normArena < 0.5) {
      dBase -= 0.05; // Leve ajuda
    }

    double dPartida = (dBase + ruido).clamp(0.0, 1.0);

    // 4. Mapeamento para Configuração (Skill Knobs)
    // Bot Level = Player Level (Fairness - NO CHEATING)
    int botLevel = nivelMedioCartas.round().clamp(1, 15);

    AiPolicy policy;
    String botId;
    double reactionTime;
    double errorRate;
    double apmCap;

    // Interpolação Linear para Knobs
    if (dPartida < 0.35) {
      botId = 'bot_iniciante';
      policy = BotBasicoPolicy();
      // Knobs Fáceis
      double t = dPartida / 0.35;
      reactionTime = _lerp(1800, 1000, t);
      errorRate = _lerp(0.30, 0.15, t);
      apmCap = _lerp(10, 20, t);
    } else if (dPartida < 0.75) {
      botId = 'bot_intermediario';
      policy = BotTaticoPolicy();
      // Knobs Médios
      double t = (dPartida - 0.35) / 0.40;
      reactionTime = _lerp(1000, 600, t);
      errorRate = _lerp(0.15, 0.05, t);
      apmCap = _lerp(20, 40, t);
    } else {
      botId = 'bot_avancado';
      policy = BotEspecialistaPolicy();
      // Knobs Difíceis
      double t = (dPartida - 0.75) / 0.25;
      reactionTime = _lerp(600, 300, t);
      errorRate = _lerp(0.05, 0.01, t);
      apmCap = _lerp(40, 80, t);
    }
    
    // Variação orgânica nos knobs
    reactionTime *= (0.9 + rng.nextDouble() * 0.2);

    return BotConfig(
      id: botId,
      policy: policy,
      reactionTimeMs: reactionTime,
      errorRate: errorRate,
      apmCap: apmCap,
      enemyCardLevel: botLevel,
    );
  }

  static double _lerp(double a, double b, double t) {
    return a + (b - a) * t.clamp(0.0, 1.0);
  }
}
