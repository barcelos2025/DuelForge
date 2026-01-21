import 'package:flutter/material.dart';
import '../../../../core/assets/asset_registry.dart';
import '../../../../ui/theme/duel_colors.dart';
import '../../../../ui/theme/duel_typography.dart';
import '../../../../ui/theme/duel_ui_tokens.dart';
import '../../../../battle/data/card_catalog.dart';

class SwapConfirmDialog extends StatelessWidget {
  final CardDefinition selectedCard;
  final CardDefinition tappedCard;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const SwapConfirmDialog({
    super.key,
    required this.selectedCard,
    required this.tappedCard,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: DuelColors.surface,
          borderRadius: BorderRadius.circular(DuelUiTokens.radiusLarge),
          border: Border.all(color: DuelColors.primary.withOpacity(0.5), width: 2),
          boxShadow: DuelUiTokens.shadowHigh,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'TROCAR CARTAS?',
              style: DuelTypography.displaySmall.copyWith(color: DuelColors.primary),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMiniCard(selectedCard),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.swap_horiz, color: Colors.white54, size: 32),
                ),
                _buildMiniCard(tappedCard),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Deseja trocar ${selectedCard.displayName} por ${tappedCard.displayName}?',
              textAlign: TextAlign.center,
              style: DuelTypography.bodyMedium,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('CANCELAR', style: DuelTypography.buttonText.copyWith(color: Colors.white54)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DuelColors.primary.withOpacity(0.2),
                      foregroundColor: DuelColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: DuelColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DuelUiTokens.radiusMedium)),
                    ),
                    child: Text('TROCAR', style: DuelTypography.buttonText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniCard(CardDefinition card) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
            image: DecorationImage(
              image: AssetImage(AssetRegistry.getCardAssetPath(card.cardId)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            card.displayName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DuelTypography.bodySmall,
          ),
        ),
      ],
    );
  }
}
