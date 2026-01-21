/// Configurações globais e mapeamentos de VFX.
class DuelForgeVfxConfig {
  // Cores Temáticas (Místico/Nórdico)
  static const int corImpactoFisico = 0xFF8D6E63; // Marrom poeira
  static const int corMagiaRunica = 0xFF00E5FF;   // Ciano Neon (suave)
  static const int corFogoBrsa = 0xFFFF5722;      // Laranja queimado
  static const int corGelo = 0xFFE0F7FA;          // Branco azulado
  static const int corVeneno = 0xFF2E7D32;        // Verde escuro (floresta)
  static const int corSangue = 0xFF8B0000;        // Vermelho escuro
  static const int corRoxoVoodoo = 0xFF7B1FA2;    // Roxo profundo

  // Mapeamento de IDs para Tipos de VFX
  static const Map<String, String> mapUnidadeAtaque = {
    'bear_berserker': 'fisico_pesado',
    'frost_ranger': 'flecha_gelo',
    'catapult': 'pedra',
    'fire_catapult': 'bola_fogo',
    'winged_demon': 'magico_sombrio',
    'thor': 'eletrico_martelo',
  };

  static const Map<String, String> mapSpellCast = {
    'poison': 'nuvem_veneno',
    'hailstorm': 'chuva_granizo',
    'lightning_cloud': 'circulo_raios',
    'voodoo_doll': 'circulo_maldicao',
    'runic_spear_rain': 'chuva_lancas', // Placeholder
  };

  // Limites de Performance
  static const int maxParticulasPorExplosao = 20;
  static const double cooldownVfxPadrao = 0.1; // Segundos entre VFX iguais
}
