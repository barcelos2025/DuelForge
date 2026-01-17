
import 'package:flutter/material.dart';
import '../../../../ui/theme/duel_colors.dart';
import '../../../../ui/theme/duel_typography.dart';
import '../../../../ui/theme/duel_ui_tokens.dart';
import '../../../battle/domain/models/arena_definition.dart';

class CurrentArenaCard extends StatelessWidget {
  final ArenaDefinition arena;

  const CurrentArenaCard({super.key, required this.arena});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DuelColors.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(DuelUiTokens.radiusMedium),
        border: Border.all(color: DuelColors.primary.withOpacity(0.3)),
        boxShadow: DuelUiTokens.shadowMedium,
      ),
      child: Row(
        children: [
          // Thumb
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
              image: DecorationImage(
                image: AssetImage(arena.assetPath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ARENA ATUAL',
                  style: DuelTypography.labelCaps.copyWith(color: DuelColors.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  arena.name,
                  style: DuelTypography.displaySmall.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  '${arena.minTrophies} - ${arena.maxTrophies == -1 ? '∞' : arena.maxTrophies} Troféus',
                  style: DuelTypography.bodySmall.copyWith(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
