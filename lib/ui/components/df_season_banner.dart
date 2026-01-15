import 'package:flutter/material.dart';
import '../../ui/theme/df_theme.dart';

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
      height: 160,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(imageAsset),
          fit: BoxFit.cover,
        ),
        boxShadow: DFTheme.shadowDepth,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.black.withOpacity( 0.8),
              Colors.transparent,
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: DFTheme.purple,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'TEMPORADA 1',
                style: DFTheme.labelBold.copyWith(fontSize: 10),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title.toUpperCase(),
              style: DFTheme.titleLarge.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: DFTheme.bodyText.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.timer, color: DFTheme.cyan, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Termina em ${_formatDuration(timeRemaining)}',
                  style: DFTheme.labelBold.copyWith(color: DFTheme.cyan),
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
