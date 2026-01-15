
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../features/battle/viewmodels/battle_view_model.dart';

class PowerBar extends StatelessWidget {
  const PowerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BattleViewModel>(
      builder: (context, vm, child) {
        final current = vm.estado.runaAtual;
        final max = 10.0;
        final progress = (current / max).clamp(0.0, 1.0);

        return Container(
          height: 20,
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.purple.withOpacity(0.5)),
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
                        colors: [Color(0xFF9C27B0), Color(0xFFE040FB)],
                      ),
                      borderRadius: BorderRadius.circular(10),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
