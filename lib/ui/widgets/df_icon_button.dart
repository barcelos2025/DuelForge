import 'package:flutter/material.dart';
import '../theme/duel_colors.dart';
import '../theme/duel_ui_tokens.dart';

class DFIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final String? tooltip;

  const DFIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = 24,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;
    final iconColor = color ?? (isDisabled ? DuelColors.textDisabled : DuelColors.textPrimary);

    Widget button = Container(
      padding: const EdgeInsets.all(DuelUiTokens.spacing8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(DuelUiTokens.radiusSmall),
      ),
      child: Icon(icon, size: size, color: iconColor),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip, child: button);
    }

    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      child: button,
    );
  }
}
