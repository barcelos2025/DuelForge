import 'package:flutter/material.dart';
import '../theme/duel_colors.dart';
import '../theme/duel_typography.dart';
import '../theme/duel_ui_tokens.dart';

class DFChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? color;

  const DFChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? DuelColors.primary;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: DuelUiTokens.spacing12,
          vertical: DuelUiTokens.spacing8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? baseColor.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(DuelUiTokens.radiusFull),
          border: Border.all(
            color: isSelected ? baseColor : DuelColors.textDisabled,
            width: 1,
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: DuelTypography.labelCaps.copyWith(
            color: isSelected ? baseColor : DuelColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
