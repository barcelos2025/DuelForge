import 'package:flutter/material.dart';
import '../models/player_card_model.dart';
import 'card_widget.dart';

class CardListExample extends StatelessWidget {
  const CardListExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final cards = [
      PlayerCardModel(
        id: '1',
        name: 'Bear Berserker',
        rarity: 'rare',
        level: 5,
        fragmentsOwned: 20,
        fragmentsRequiredNext: 50,
        isObtained: true,
        assetPath: 'assets/cards/unit_bear_berserker.png',
        elixirCost: 4,
      ),
      PlayerCardModel(
        id: '2',
        name: 'Frost Ranger',
        rarity: 'common',
        level: 8,
        fragmentsOwned: 400,
        fragmentsRequiredNext: 200, // Ready to upgrade
        isObtained: true,
        assetPath: 'assets/cards/unit_frost_ranger.png',
        elixirCost: 3,
      ),
      PlayerCardModel(
        id: '3',
        name: 'Winged Demon',
        rarity: 'legendary',
        level: 1,
        fragmentsOwned: 0,
        fragmentsRequiredNext: 2,
        isObtained: false,
        assetPath: 'assets/cards/unit_winged_demon.png',
        elixirCost: 5,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0B1221),
      body: Center(
        child: SizedBox(
          height: 200,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            scrollDirection: Axis.horizontal,
            itemCount: cards.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return CardWidget(
                card: cards[index],
                onTap: () => print('Tapped ${cards[index].name}'),
                onLongPress: () => print('Details ${cards[index].name}'),
              );
            },
          ),
        ),
      ),
    );
  }
}
