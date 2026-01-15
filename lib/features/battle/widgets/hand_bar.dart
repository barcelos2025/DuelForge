
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/carta.dart';
import '../viewmodels/battle_view_model.dart';

class HandBar extends StatelessWidget {
  final void Function(Carta carta, int lane) onPlay;
  const HandBar({super.key, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BattleViewModel>();
    final mao = vm.mao;
    final selecionada = vm.cartaSelecionadaAtual();

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity( 0.75),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final carta in mao)
            _CartaWidget(
              carta: carta,
              selecionada: selecionada?.id == carta.id,
              pode: vm.podeJogar(carta),
              onTap: () => vm.selecionarCarta(carta),
              onPlay: () {
                if (vm.cartaSelecionadaAtual()?.id != carta.id) {
                  vm.selecionarCarta(carta);
                  return;
                }
                onPlay(carta, vm.laneSelecionada);
              },
            ),
        ],
      ),
    );
  }
}

class _CartaWidget extends StatelessWidget {
  final Carta carta;
  final bool selecionada;
  final bool pode;
  final VoidCallback onTap;
  final VoidCallback onPlay;

  const _CartaWidget({
    required this.carta,
    required this.selecionada,
    required this.pode,
    required this.onTap,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final cor = _corPorRaridade(carta.raridade);

    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onPlay,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 76,
        height: selecionada ? 112 : 106,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity( 0.45),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selecionada ? Colors.white.withOpacity( 0.55) : cor.withOpacity( 0.55),
            width: selecionada ? 2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 14,
              spreadRadius: 1,
              color: selecionada ? Colors.white.withOpacity( 0.12) : Colors.black.withOpacity( 0.2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                _CustoBadge(valor: carta.custo, ativo: pode),
                const Spacer(),
                _PoderBadge(valor: carta.poder, cor: cor),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: Icon(
                  _iconePorTipo(carta.tipo),
                  size: 30,
                  color: pode ? Colors.white : Colors.white54,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              carta.nome,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                height: 1.05,
                color: pode ? Colors.white : Colors.white60,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustoBadge extends StatelessWidget {
  final int valor;
  final bool ativo;
  const _CustoBadge({required this.valor, required this.ativo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: ativo ? const Color(0xFF2B7CFF).withOpacity( 0.9) : Colors.white10,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$valor',
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _PoderBadge extends StatelessWidget {
  final int valor;
  final Color cor;
  const _PoderBadge({required this.valor, required this.cor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withOpacity( 0.85),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'P$valor',
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
      );
  }
}

IconData _iconePorTipo(TipoCarta tipo) {
  switch (tipo) {
    case TipoCarta.tropa:
      return Icons.shield;
    case TipoCarta.feitico:
      return Icons.auto_fix_high;
    case TipoCarta.construcao:
      return Icons.cabin;
  }
}

Color _corPorRaridade(String raridade) {
  switch (raridade.toLowerCase()) {
    case 'rara':
      return const Color(0xFF3DB6FF);
    case 'epica':
    case 'épica':
      return const Color(0xFFB35CFF);
    case 'lendária':
    case 'lendaria':
      return const Color(0xFFFFC44D);
    case 'mestre':
      return const Color(0xFFFF5D5D);
    default:
      return const Color(0xFF8BEA7C);
  }
}
