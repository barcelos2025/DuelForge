import 'package:flutter/material.dart';
import '../../ui/theme/duel_colors.dart';
import '../../ui/theme/duel_typography.dart';
import '../../ui/theme/duel_ui_tokens.dart';

class DFSeasonBanner extends StatelessWidget {
  final String title;
  final String description;
  final String imageAsset;
  final Duration timeRemaining;

  const DFSeasonBanner({
    super.key,
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.timeRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Removed fixed height: 160 to allow Flexible parent to control size
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(imageAsset),
          fit: BoxFit.cover,
        ),
        boxShadow: DuelUiTokens.shadowMedium,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        padding: const EdgeInsets.all(16), // Reduced padding slightly
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Allow shrinking
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: DuelColors.secondary,
                borderRadius: BorderRadius.circular(DuelUiTokens.radiusSmall),
              ),
              child: Text(
                'TEMPORADA 1',
                style: DuelTypography.labelCaps.copyWith(color: Colors.white, fontSize: 10),
              ),
            ),
            const SizedBox(height: 4), // Reduced spacing
            Flexible( // Allow text to shrink or wrap safely
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  title.toUpperCase(),
                  style: DuelTypography.displayMedium,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                description,
                style: DuelTypography.bodyMedium.copyWith(color: Colors.white70, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.timer, color: DuelColors.primary, size: 12),
                const SizedBox(width: 4),
                Text(
                  'Termina em ${_formatDuration(timeRemaining)}',
                  style: DuelTypography.labelCaps.copyWith(color: DuelColors.primary, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    return '${d.inDays}d';
  }
}
