import 'package:flutter/material.dart';
import '../theme/duel_colors.dart';
import '../theme/duel_ui_tokens.dart';

class DFCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Border? border;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const DFCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.border,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(DuelUiTokens.spacing16),
      decoration: BoxDecoration(
        color: backgroundColor ?? DuelColors.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(DuelUiTokens.radiusMedium),
        border: border ?? Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: DuelUiTokens.shadowLow,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
