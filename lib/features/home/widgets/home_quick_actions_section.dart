import 'package:flutter/material.dart';
import '../../../ui/theme/df_theme.dart';

class QuickActionItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color? accentColor;

  QuickActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.accentColor,
  });
}

class HomeQuickActionsSection extends StatelessWidget {
  final List<QuickActionItem> actions;

  const HomeQuickActionsSection({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: actions.map((action) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _QuickActionCard(item: action),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final QuickActionItem item;

  const _QuickActionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        height: 110,
        decoration: DFTheme.glassPanelDecoration.copyWith(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: (item.accentColor ?? Colors.white).withValues(alpha:  0.15),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Fundo decorativo (Runas discretas ou gradiente)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (item.accentColor ?? Colors.blueGrey).withValues(alpha:  0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            // Conteúdo
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Ícone
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha:  0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: item.accentColor ?? Colors.white, size: 20),
                  ),
                  
                  // Textos
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: DFTheme.titleMedium.copyWith(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: const TextStyle(fontSize: 10, color: Colors.white54),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Seta indicativa
            Positioned(
              top: 12,
              right: 12,
              child: Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: Colors.white.withValues(alpha:  0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
