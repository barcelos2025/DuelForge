import 'package:flutter/material.dart';
import '../../../ui/components/df_season_banner.dart';

class HomeSeasonBannerSection extends StatelessWidget {
  const HomeSeasonBannerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: DFSeasonBanner(
        title: 'Inverno Eterno',
        description: 'Ganhe recompensas gélidas!',
        imageAsset: 'assets/images/feitiço de congelamento.jpeg', // Placeholder
        timeRemaining: Duration(days: 12),
      ),
    );
  }
}
