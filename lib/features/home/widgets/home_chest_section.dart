import 'package:flutter/material.dart';
import '../../../ui/components/df_chest_carousel.dart';

class HomeChestSection extends StatelessWidget {
  const HomeChestSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: DFChestCarousel(
        slots: [
          ChestItemModel(
            id: 'chest_1',
            rarity: ChestRarity.rare,
            state: ChestState.ready,
          ),
          ChestItemModel(
            id: 'chest_2',
            rarity: ChestRarity.common,
            state: ChestState.unlocking,
            remainingTime: const Duration(minutes: 45),
            totalTime: const Duration(hours: 3),
          ),
          ChestItemModel(
            id: 'chest_3',
            rarity: ChestRarity.epic,
            state: ChestState.locked,
            totalTime: const Duration(hours: 8),
          ),
          ChestItemModel(
            id: 'chest_4',
            state: ChestState.empty,
          ),
        ],
        onOpen: (id) => debugPrint('Open chest $id'),
        onSpeedUp: (id) => debugPrint('Speed up chest $id'),
        onEmptySlotTap: () => debugPrint('Empty slot tapped'),
      ),
    );
  }
}
