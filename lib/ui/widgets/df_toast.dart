import 'package:flutter/material.dart';
import '../theme/duel_colors.dart';
import '../theme/duel_typography.dart';
import '../theme/duel_ui_tokens.dart';

class DFToast {
  static void show(BuildContext context, {required String message, bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? Colors.white : Colors.black,
              size: 20,
            ),
            const SizedBox(width: DuelUiTokens.spacing12),
            Expanded(
              child: Text(
                message,
                style: DuelTypography.bodyMedium.copyWith(
                  color: isError ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? DuelColors.error : DuelColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DuelUiTokens.radiusMedium),
        ),
        margin: const EdgeInsets.all(DuelUiTokens.spacing16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
