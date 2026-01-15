
class EstadoBatalha {
  double runaAtual;
  double runaMax;
  double regenPorSegundo;

  bool emPausa;

  EstadoBatalha({
    required this.runaAtual,
    required this.runaMax,
    required this.regenPorSegundo,
    this.emPausa = false,
  });
}
