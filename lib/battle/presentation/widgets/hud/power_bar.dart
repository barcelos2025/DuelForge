
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../features/battle/viewmodels/battle_view_model.dart';
import '../../../../ui/theme/duel_colors.dart';
import '../../../../ui/theme/duel_typography.dart';
import '../../../../ui/theme/duel_ui_tokens.dart';

class PowerBar extends StatelessWidget {
  const PowerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BattleViewModel>(
      builder: (context, vm, child) {
        final current = vm.estado.runaAtual;
        if (current < 10.0) print('📊 PowerBar Build: ${current.toStringAsFixed(2)}');
        final max = 10.0;
        final progress = (current / max).clamp(0.0, 1.0);

        return Container(
          height: 17,
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(DuelUiTokens.radiusFull),
            border: Border.all(color: DuelColors.secondary.withOpacity(0.5)),
          ),
          child: Stack(
            children: [
              // Bar
              LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [DuelColors.secondary, Color(0xFFE040FB)],
                      ),
                      borderRadius: BorderRadius.circular(DuelUiTokens.radiusFull),
                    ),
                  );
                },
              ),
              
              // Segments (10)
              Row(
                children: List.generate(10, (index) {
                  return Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: index < 9 
                              ? BorderSide(color: Colors.black.withOpacity(0.2), width: 1)
                              : BorderSide.none,
                        ),
                      ),
                    ),
                  );
                }),
              ),

              // Text
              Center(
                child: Text(
                  '${current.toInt()}/10',
                  style: DuelTypography.hudNumber.copyWith(fontSize: 14, height: 1.0),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
