
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../features/battle/viewmodels/battle_view_model.dart';
import 'hand_cards_row.dart';
import 'power_bar.dart';

class BattleHud extends StatelessWidget {
  const BattleHud({super.key});

  @override
  Widget build(BuildContext context) {
    // Height is 23% of screen
    final height = MediaQuery.of(context).size.height * 0.23;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2C).withOpacity(0.95),
          border: const Border(
            top: BorderSide(color: Color(0xFF3E3E4C), width: 2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            // Power Bar & Cancel
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
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
            Expanded(
              child: const HandCardsRow(),
            ),
          ],
        ),
      ),
    );
  }
}
