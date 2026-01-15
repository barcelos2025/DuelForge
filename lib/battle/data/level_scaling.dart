
import 'dart:math';

class LevelScaling {
  /// Calcula o multiplicador de atributos baseado no nível.
  /// Fórmula: 1.08^(nivel - 1)
  static double levelMultiplier(int level) {
    if (level < 1) return 1.0;
    return pow(1.08, level - 1).toDouble();
  }

  /// Retorna o nível efetivo da carta baseado na raridade.
  /// Comum: Nível 1
  /// Rara: Nível 3 (+2)
  /// Épica: Nível 6 (+5)
  /// Lendária: Nível 9 (+8)
  /// Mestre: Nível 11 (+10)
  static int getLevelBonus(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'comum':
        return 0;
      case 'rara':
        return 2;
      case 'epica':
        return 5;
      case 'lendaria':
        return 8;
      case 'mestre':
        return 10;
      default:
        return 0;
    }
  }

  /// Aplica o multiplicador aos stats base.
  /// Arredonda HP e Dano para inteiros.
  static Map<String, dynamic> scaleStats(int baseHp, int baseDamage, int level) {
    final mult = levelMultiplier(level);
    return {
      'hp': (baseHp * mult).round(),
      'damage': (baseDamage * mult).round(),
    };
  }
}
