import 'package:flutter/material.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../ui/theme/duel_colors.dart';
import '../../../../ui/theme/duel_typography.dart';
import '../../../../ui/theme/duel_ui_tokens.dart';

class DeckHeader extends StatelessWidget {
  final int cardCount;
  final double averageCost;

  const DeckHeader({
    super.key,
    required this.cardCount,
    required this.averageCost,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SEU DECK DE BATALHA', style: DuelTypography.displaySmall),
              const SizedBox(height: 4),
              Text(
                '$cardCount/8 Cartas Selecionadas',
                style: DuelTypography.bodySmall,
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: DuelColors.surfaceHighlight,
              borderRadius: BorderRadius.circular(DuelUiTokens.radiusFull),
              border: Border.all(color: DuelColors.secondary.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.water_drop, color: DuelColors.secondary, size: 16),
                const SizedBox(width: 4),
                Text(
                  NumberFormatter.formatDecimal(averageCost, 1),
                  style: DuelTypography.hudNumber.copyWith(color: DuelColors.secondary, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
