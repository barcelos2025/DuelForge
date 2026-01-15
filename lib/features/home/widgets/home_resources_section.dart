import 'package:flutter/material.dart';
import '../../../ui/theme/df_theme.dart';
import '../../../ui/components/df_resource_pills.dart';

class HomeResourcesSection extends StatelessWidget {
  const HomeResourcesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DFResourcePills(
            items: [
              ResourceItem(
                label: 'Ouro',
                value: 2450,
                icon: Icons.monetization_on,
                accentColor: DFTheme.gold,
                onTap: () => debugPrint('Gold tapped'),
              ),
              ResourceItem(
                label: 'Gemas',
                value: 120,
                icon: Icons.diamond,
                accentColor: DFTheme.cyan,
                onTap: () => debugPrint('Gems tapped'),
              ),
              ResourceItem(
                label: 'Runas',
                value: 45,
                icon: Icons.flash_on,
                accentColor: DFTheme.purple,
                onTap: () => debugPrint('Runes tapped'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
