import 'package:flutter/material.dart';
import '../../../ui/components/df_top_bar.dart';

class HomeHeaderSection extends StatelessWidget {
  final VoidCallback? onSettingsTap;

  const HomeHeaderSection({super.key, this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return DFTopBar(
      playerName: 'Jarl Bjorn',
      playerLevel: 4,
      trophies: 1250,
      rankLabel: 'Elo Rúnico',
      onTapSettings: onSettingsTap,
      onTapProfile: () => debugPrint('Profile tapped'),
    );
  }
}
