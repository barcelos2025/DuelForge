class BotSkillKnobs {
  final double apm; // 0.0 (Lento) a 1.0 (Rápido)
  final double reactionTimeMs; // 250ms a 1200ms
  final double qualityTarget; // 0.0 (Aleatório) a 1.0 (Ótimo)
  final double spellUsage; // 0.0 (Ruim) a 1.0 (Perfeito)
  final double cycleControl; // 0.0 (Nenhum) a 1.0 (Segura cartas)
  final double shortTermPlanning; // 0.0 (Reativo) a 1.0 (Preditivo)
  final double intentionalError; // 0.0 (Sem erro) a 1.0 (Muitos erros)
  final double laneAggression; // 0.0 (Passivo) a 1.0 (Agressivo)

  const BotSkillKnobs({
    required this.apm,
    required this.reactionTimeMs,
    required this.qualityTarget,
    required this.spellUsage,
    required this.cycleControl,
    required this.shortTermPlanning,
    required this.intentionalError,
    required this.laneAggression,
  });

  @override
  String toString() {
    return 'Knobs(APM:${apm.toStringAsFixed(2)}, React:${reactionTimeMs.toInt()}ms, Err:${intentionalError.toStringAsFixed(2)})';
  }
}
