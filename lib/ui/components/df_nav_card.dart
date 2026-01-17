import 'package:flutter/material.dart';
import '../../ui/theme/duel_colors.dart';
import '../../ui/theme/duel_typography.dart';
import '../../ui/theme/duel_ui_tokens.dart';

class DFNavCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String imageAsset;
  final VoidCallback onTap;
  final Color? overlayColor;

  const DFNavCard({
    super.key,
    required this.title,
    required this.imageAsset,
    required this.onTap,
    this.subtitle,
    this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DuelUiTokens.radiusMedium),
          boxShadow: DuelUiTokens.shadowMedium,
          image: DecorationImage(
            image: AssetImage(imageAsset),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity( 0.3),
              BlendMode.darken,
            ),
          ),
          border: Border.all(color: Colors.white.withOpacity( 0.15)),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity( 0.8),
              ],
              stops: const [0.5, 1.0],
            ),
          ),
          padding: const EdgeInsets.all(16),
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: DuelTypography.displaySmall.copyWith(fontSize: 18),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: DuelTypography.bodySmall.copyWith(fontSize: 12, color: DuelColors.primary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
