import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../ui/theme/duel_colors.dart';
import '../../../../ui/theme/duel_typography.dart';
import '../../../../ui/theme/duel_ui_tokens.dart';

class DuelForgeBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const DuelForgeBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80, // Taller for premium feel
      decoration: BoxDecoration(
        color: const Color(0xFF0B1320).withOpacity(0.95),
        border: const Border(
          top: BorderSide(color: Color(0xFF1F3A5A), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home, 'Início', isMain: true),
            _buildNavItem(1, Icons.style, 'Deck'),
            _buildNavItem(2, Icons.auto_awesome, 'Evoluir'),
            _buildNavItem(3, Icons.storefront, 'Loja'),
            _buildNavItem(4, Icons.sports_kabaddi, 'Arena'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, {bool isMain = false}) {
    final isSelected = currentIndex == index;
    final color = isSelected ? DuelColors.primary : Colors.white24;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap(index);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(isMain ? 12 : 8),
              decoration: isMain && isSelected
                  ? BoxDecoration(
                      color: DuelColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: DuelColors.primary.withOpacity(0.2),
                          blurRadius: 12,
                        ),
                      ],
                    )
                  : null,
              child: Icon(
                icon,
                color: color,
                size: isMain ? 28 : 24,
              ),
            ),
            if (!isMain) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
