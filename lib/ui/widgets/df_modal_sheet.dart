import 'package:flutter/material.dart';
import '../theme/duel_colors.dart';
import '../theme/duel_ui_tokens.dart';

class DFModalSheet extends StatelessWidget {
  final Widget child;
  final String? title;

  const DFModalSheet({
    super.key,
    required this.child,
    this.title,
  });

  static Future<T?> show<T>(BuildContext context, {required Widget child, String? title}) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DFModalSheet(title: title, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: DuelColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(DuelUiTokens.radiusLarge)),
        boxShadow: [
          BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 5),
        ],
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: DuelUiTokens.spacing12),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(DuelUiTokens.radiusFull),
              ),
            ),
          ),
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DuelUiTokens.spacing24),
              child: Text(
                title!,
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: DuelUiTokens.spacing16),
          ],
          Flexible(child: child),
        ],
      ),
    );
  }
}
