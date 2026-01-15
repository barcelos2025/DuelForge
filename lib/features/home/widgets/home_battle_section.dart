import 'package:flutter/material.dart';
import '../../../ui/components/df_primary_cta.dart';

class HomeBattleSection extends StatelessWidget {
  final VoidCallback onBattleTap;

  const HomeBattleSection({super.key, required this.onBattleTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          DFPrimaryCTA(
            title: 'BATALHAR',
            subtitle: 'Entrar na arena',
            leftIcon: Icons.flash_on,
            onPressed: onBattleTap,
          ),
        ],
      ),
    );
  }
}
