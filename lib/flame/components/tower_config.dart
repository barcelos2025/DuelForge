/// Enumeração para os tipos de torre disponíveis.
enum TipoTorre {
  lateral, // Torre da Princesa
  central, // Torre do Rei
}

/// Enumeração para os times.
enum TimeTorre {
  jogador, // Azul
  inimigo, // Vermelho
}

/// Configuração base para as torres (Tuning).
class TowerConfig {
  // --- Torre Lateral (Princesa) ---
  static const double hpLateral = 1400.0;
  static const double alcanceLateral = 250.0; // ~7.5 tiles (escala 1000u)
  static const double cadenciaLateral = 0.8; // Segundos
  static const double danoLateral = 90.0;

  // --- Torre Central (Rei) ---
  static const double hpCentral = 2400.0;
  static const double alcanceCentral = 300.0; // ~8.0 tiles
  static const double cadenciaCentral = 1.0;
  static const double danoCentral = 110.0;

  // --- Visual ---
  static const double raioBaseVisual = 40.0; // Raio visual do placeholder
  static const double larguraBarraVida = 60.0;
  static const double alturaBarraVida = 8.0;
}
