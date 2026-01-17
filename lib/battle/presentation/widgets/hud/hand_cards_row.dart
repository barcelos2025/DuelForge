
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../features/battle/viewmodels/battle_view_model.dart';
import '../../../../features/battle/models/carta.dart';
import '../../../../ui/theme/duel_colors.dart';

class HandCardsRow extends StatelessWidget {
  const HandCardsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BattleViewModel>(
      builder: (context, vm, child) {
        final hand = vm.mao;
        final currentPower = vm.estado.runaAtual;
        final selected = vm.cartaSelecionada;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: hand.map((carta) {
            final canAfford = currentPower >= carta.custo;
            final isSelected = selected?.id == carta.id;

            return GestureDetector(
              onTap: () {
                if (canAfford) {
                  vm.selecionarCarta(carta);
                } else {
                  // Shake or feedback?
                }
              },
              child: _CardSlot(
                carta: carta,
                canAfford: canAfford,
                isSelected: isSelected,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _CardSlot extends StatelessWidget {
  final Carta carta;
  final bool canAfford;
  final bool isSelected;

  const _CardSlot({
    required this.carta,
    required this.canAfford,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Resolve Rarity Color
    Color borderColor = Colors.white10;
    Color shadowColor = Colors.transparent;
    
    // Map string rarity to color
    switch (carta.raridade.toLowerCase()) {
      case 'comum':
      case 'common':
        borderColor = DuelColors.rarityCommon;
        break;
      case 'rara':
      case 'rare':
        borderColor = DuelColors.rarityRare;
        break;
      case 'epica':
      case 'epic':
        borderColor = DuelColors.rarityEpic;
        break;
      case 'lendaria':
      case 'legendary':
        borderColor = DuelColors.rarityLegendary;
        break;
    }
    shadowColor = borderColor.withOpacity(0.25);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isSelected ? 80 : 70,
      height: isSelected ? 100 : 90,
      margin: EdgeInsets.only(bottom: isSelected ? 10 : 0),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          // If selected, use Cyan. If not selected but can afford, use Rarity Color. If cannot afford, use Red/Dimmed.
          color: isSelected 
              ? Colors.cyanAccent 
              : (canAfford ? borderColor : Colors.red.withOpacity(0.5)),
          width: isSelected ? 3 : 2,
        ),
        boxShadow: [
          // Rarity Glow (always present if affordable, or just subtle)
          if (canAfford && !isSelected)
            BoxShadow(
              color: shadowColor,
              blurRadius: 8,
              spreadRadius: 1,
            ),
          // Selection Glow
          if (isSelected)
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.4), 
              blurRadius: 10, 
              spreadRadius: 2
            ),
        ],
      ),
      child: Stack(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Opacity(
              opacity: canAfford ? 1.0 : 0.5,
              child: Image.asset(
                carta.imagePath ?? '',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[800],
                  child: Center(
                    child: Text(
                      carta.nome.substring(0, 2).toUpperCase(),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Cost Badge
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${carta.custo}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          // Level/Rarity Indicator (Optional)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
              ),
              child: Text(
                carta.nome,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 8),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
