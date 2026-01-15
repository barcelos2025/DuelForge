
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/battle_view_model.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BattleViewModel>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Row(
        children: [
          _Badge(
            label: 'RUNA',
            value: '${vm.estado.runaAtual.toStringAsFixed(1)}/${vm.estado.runaMax.toStringAsFixed(0)}',
          ),
          const SizedBox(width: 10),
          _LaneSelector(
            lane: vm.laneSelecionada,
            onChange: vm.selecionarLane,
          ),
          const Spacer(),
          IconButton(
            onPressed: vm.alternarPausa,
            icon: Icon(vm.estado.emPausa ? Icons.play_arrow : Icons.pause),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final String value;

  const _Badge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity( 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity( 0.12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _LaneSelector extends StatelessWidget {
  final int lane;
  final void Function(int) onChange;

  const _LaneSelector({required this.lane, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity( 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity( 0.12)),
      ),
      child: Row(
        children: [
          _LaneButton(texto: 'Topo', ativo: lane == 0, onTap: () => onChange(0)),
          const SizedBox(width: 6),
          _LaneButton(texto: 'Baixo', ativo: lane == 1, onTap: () => onChange(1)),
        ],
      ),
    );
  }
}

class _LaneButton extends StatelessWidget {
  final String texto;
  final bool ativo;
  final VoidCallback onTap;

  const _LaneButton({required this.texto, required this.ativo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: ativo ? Colors.white.withOpacity( 0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: ativo ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }
}
