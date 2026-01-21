
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../features/battle/viewmodels/battle_view_model.dart';
import 'hand_cards_row.dart';
import 'power_bar.dart';

class BattleHud extends StatelessWidget {
  const BattleHud({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 39, top: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
              // Power Bar & Cancel
              Padding(
                padding: const EdgeInsets.only(bottom: 27.0, top: 4.0),
                child: Consumer<BattleViewModel>(
                  builder: (context, vm, _) {
                    final hasSelection = vm.cartaSelecionada != null;
                    return SizedBox(
                      height: 24, // Altura fixa para evitar pulos quando o botão X aparecer
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: const PowerBar()),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Hand Cards
              const HandCardsRow(),
            ],
          ),
        ),
      );
  }
}
