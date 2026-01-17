
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
                padding: const EdgeInsets.only(bottom: 26.0, top: 4.0),
                child: Consumer<BattleViewModel>(
                  builder: (context, vm, _) {
                    final hasSelection = vm.cartaSelecionada != null;
                    return Row(
                      children: [
                        Expanded(child: const PowerBar()),
                        if (hasSelection) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => vm.selecionarCarta(null),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1),
                              ),
                              child: const Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ],
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
