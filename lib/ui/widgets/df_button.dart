import 'package:flutter/material.dart';
import '../theme/duel_colors.dart';
import '../theme/duel_typography.dart';
import '../theme/duel_ui_tokens.dart';

enum DFButtonType { primary, secondary, ghost, danger }

class DFButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final DFButtonType type;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const DFButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = DFButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  const DFButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  }) : type = DFButtonType.primary;

  const DFButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  }) : type = DFButtonType.secondary;

  const DFButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  }) : type = DFButtonType.ghost;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    Color bgColor;
    Color textColor;
    Border? border;
    List<BoxShadow> shadows = [];

    switch (type) {
      case DFButtonType.primary:
        bgColor = isDisabled ? DuelColors.surfaceHighlight : DuelColors.primary;
        textColor = isDisabled ? DuelColors.textDisabled : Colors.black;
        if (!isDisabled) shadows = DuelUiTokens.glowCyan;
        break;
      case DFButtonType.secondary:
        bgColor = Colors.transparent;
        textColor = isDisabled ? DuelColors.textDisabled : DuelColors.primary;
        border = Border.all(
          color: isDisabled ? DuelColors.textDisabled : DuelColors.primary,
          width: 1.5,
        );
        break;
      case DFButtonType.ghost:
        bgColor = Colors.transparent;
        textColor = isDisabled ? DuelColors.textDisabled : DuelColors.textSecondary;
        break;
      case DFButtonType.danger:
        bgColor = DuelColors.error;
        textColor = Colors.white;
        break;
    }

    Widget content = Container(
      height: 48,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: DuelUiTokens.spacing24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(DuelUiTokens.radiusMedium),
        border: border,
        boxShadow: shadows,
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: textColor,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: textColor),
                  const SizedBox(width: DuelUiTokens.spacing8),
                ],
                Text(
                  label.toUpperCase(),
                  style: DuelTypography.buttonText.copyWith(color: textColor),
                ),
              ],
            ),
    );

    if (isFullWidth) {
      content = SizedBox(width: double.infinity, child: content);
    }

    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      child: Opacity(
        opacity: isDisabled ? 0.6 : 1.0,
        child: content,
      ),
    );
  }
}
