import 'package:flutter/material.dart';
import '../../../../ui/theme/df_theme.dart';
import '../../../../app/navigation/rotas.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  title: 'Deck',
                  subtitle: 'Monte seu set',
                  icon: Icons.style,
                  color: DFTheme.cyan,
                  route: Rotas.deck,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  context,
                  title: 'Evoluir',
                  subtitle: 'Aumente poder',
                  icon: Icons.auto_awesome,
                  color: DFTheme.purple,
                  route: Rotas.upgrade,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  title: 'Loja',
                  subtitle: 'Recursos',
                  icon: Icons.storefront,
                  color: DFTheme.gold,
                  route: Rotas.shop,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  context,
                  title: 'Replays',
                  subtitle: 'Reveja partidas',
                  icon: Icons.play_circle_outline,
                  color: Colors.deepOrange,
                  onTap: () => debugPrint('Replays tapped'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    String? route,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        if (route != null) {
          Navigator.pushNamed(context, route);
        } else {
          onTap?.call();
        }
      },
      child: Container(
        height: 100,
        decoration: DFTheme.glassPanelDecoration.copyWith(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Stack(
          children: [
            // Subtle Gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: DFTheme.titleMedium.copyWith(fontSize: 16),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
