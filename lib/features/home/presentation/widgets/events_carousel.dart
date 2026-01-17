import 'package:flutter/material.dart';
import '../../../../ui/theme/duel_colors.dart';
import '../../../../ui/theme/duel_typography.dart';
import '../../../../ui/theme/duel_ui_tokens.dart';

class EventsCarousel extends StatelessWidget {
  const EventsCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'EVENTOS & NOVIDADES',
            style: DuelTypography.labelCaps.copyWith(color: Colors.white54),
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildEventCard(
                title: 'Desafio do Dragão',
                reward: 'Baú Épico',
                color: Colors.redAccent,
                icon: Icons.local_fire_department,
              ),
              const SizedBox(width: 12),
              _buildEventCard(
                title: 'Corrida do Ouro',
                reward: '2x Ouro',
                color: DuelColors.accentGold,
                icon: Icons.monetization_on,
              ),
              const SizedBox(width: 12),
              _buildEventCard(
                title: 'Torneio Rúnico',
                reward: 'Skin Exclusiva',
                color: DuelColors.primary,
                icon: Icons.auto_awesome,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard({
    required String title,
    required String reward,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DuelUiTokens.radiusLarge),
        color: DuelColors.surface,
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: DuelUiTokens.shadowMedium,
      ),
      child: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    color.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 20),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ATIVO',
                        style: DuelTypography.labelCaps.copyWith(
                          color: color,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  title,
                  style: DuelTypography.displaySmall.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Recompensa: ',
                      style: DuelTypography.bodySmall.copyWith(color: Colors.white54, fontSize: 12),
                    ),
                    Text(
                      reward,
                      style: DuelTypography.labelCaps.copyWith(color: color, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
