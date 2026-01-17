import 'package:flutter/material.dart';
import '../../domain/deck_types.dart';
import '../../../../ui/theme/duel_colors.dart';
import '../../../../ui/theme/duel_ui_tokens.dart';

class SortOrderToggleButton extends StatelessWidget {
  final SortOrder sortOrder;
  final VoidCallback onTap;

  const SortOrderToggleButton({
    super.key,
    required this.sortOrder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: DuelColors.surfaceHighlight,
          borderRadius: BorderRadius.circular(DuelUiTokens.radiusMedium),
          border: Border.all(color: Colors.white12),
          boxShadow: DuelUiTokens.shadowLow,
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 120),
            child: Icon(
              sortOrder == SortOrder.asc 
                  ? Icons.arrow_upward 
                  : Icons.arrow_downward,
              key: ValueKey(sortOrder),
              color: DuelColors.primary,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
