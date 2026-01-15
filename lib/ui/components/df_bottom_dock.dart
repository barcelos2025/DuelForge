import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/df_theme.dart';

class DFBottomDock extends StatelessWidget {
  final int currentIndex;
  final Function(int) onChange;

  const DFBottomDock({
    super.key,
    required this.currentIndex,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 80 + MediaQuery.of(context).padding.bottom / 2,
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom / 2),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1926).withOpacity( 0.85),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity( 0.1), width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity( 0.5),
                offset: const Offset(0, -4),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _DockItem(
                index: 0,
                icon: Icons.storefront,
                label: 'Loja',
                isSelected: currentIndex == 0,
                onTap: onChange,
              ),
              _DockItem(
                index: 1,
                icon: Icons.style,
                label: 'Deck',
                isSelected: currentIndex == 1,
                onTap: onChange,
              ),
              _DockItem(
                index: 2,
                icon: Icons.auto_awesome,
                label: 'Evoluir',
                isSelected: currentIndex == 2,
                onTap: onChange,
              ),
              _DockItem(
                index: 3,
                icon: Icons.shield, // Arena
                label: 'Arena',
                isSelected: currentIndex == 3,
                onTap: onChange,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final bool isSelected;
  final Function(int) onTap;

  const _DockItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? DFTheme.gold : Colors.white38;
    
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 64,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? DFTheme.gold.withOpacity( 0.15) : Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: DFTheme.gold.withOpacity( 0.2),
                          blurRadius: 12,
                          spreadRadius: 2,
                        )
                      ]
                    : [],
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
            ] else
              const SizedBox(height: 16), // Spacer to keep alignment
          ],
        ),
      ),
    );
  }
}
