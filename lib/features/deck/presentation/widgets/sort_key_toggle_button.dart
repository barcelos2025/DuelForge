import 'package:flutter/material.dart';
import '../../domain/deck_types.dart';
import '../../../../ui/theme/duel_colors.dart';
import '../../../../ui/theme/duel_typography.dart';
import '../../../../ui/theme/duel_ui_tokens.dart';

class SortKeyToggleButton extends StatelessWidget {
  final ReserveSortKey sortKey;
  final VoidCallback onTap;

  const SortKeyToggleButton({
    super.key,
    required this.sortKey,
    required this.onTap,
  });

  String get _label {
    switch (sortKey) {
      case ReserveSortKey.type:
        return 'TIPO';
      case ReserveSortKey.rarity:
        return 'RAR';
      case ReserveSortKey.power:
        return 'PODER';
      case ReserveSortKey.level:
        return 'NÍVEL';
    }
  }

  IconData get _icon {
    switch (sortKey) {
      case ReserveSortKey.type:
        return Icons.category;
      case ReserveSortKey.rarity:
        return Icons.star;
      case ReserveSortKey.power:
        return Icons.flash_on;
      case ReserveSortKey.level:
        return Icons.upgrade;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: DuelUiTokens.spacing16),
        decoration: BoxDecoration(
          color: DuelColors.surfaceHighlight,
          borderRadius: BorderRadius.circular(DuelUiTokens.radiusMedium),
          border: Border.all(color: Colors.white12),
          boxShadow: DuelUiTokens.shadowLow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, color: DuelColors.primary, size: 18),
            const SizedBox(width: DuelUiTokens.spacing8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 120),
              child: Text(
                _label,
                key: ValueKey(sortKey),
                style: DuelTypography.buttonText.copyWith(
                  color: DuelColors.textPrimary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
