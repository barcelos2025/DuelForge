import 'package:flutter/material.dart';
import '../../../../battle/data/card_catalog.dart';
import '../../../../ui/theme/duel_colors.dart';
import '../../../../ui/theme/duel_typography.dart';
import '../../domain/deck_types.dart';
import 'deck_card_widget.dart';
import '../anim/card_rect_registry.dart';

class CardCollectionGrid extends StatelessWidget {
  final List<CardDefinition> allCards;
  final List<String> currentDeck;
  final SelectedCardRef? selectedRef;
  final Function(String, int) onCardTap;
  final CardRectRegistry registry;
  final bool isSwapping;
  final SelectedCardRef? swappingSource;
  final SelectedCardRef? swappingTarget;

  const CardCollectionGrid({
    super.key,
    required this.allCards,
    required this.currentDeck,
    required this.selectedRef,
    required this.onCardTap,
    required this.registry,
    this.isSwapping = false,
    this.swappingSource,
    this.swappingTarget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            'SUA COLEÇÃO',
            style: DuelTypography.labelCaps.copyWith(color: DuelColors.textSecondary),
          ),
        ),
        Expanded(
          child: allCards.isEmpty 
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off, size: 48, color: DuelColors.textDisabled),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma carta encontrada',
                        style: DuelTypography.bodyMedium.copyWith(color: DuelColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 32), // Extra top padding for glow
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.75,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: allCards.length,
            itemBuilder: (context, index) {
              final card = allCards[index];
              final isSelected = selectedRef?.side == DeckSide.reserve && selectedRef?.index == index;

              final isPlaceholder = isSwapping && 
                  ((swappingSource?.side == DeckSide.reserve && swappingSource?.index == index) ||
                   (swappingTarget?.side == DeckSide.reserve && swappingTarget?.index == index));

              return DeckCardWidget(
                cardId: card.cardId,
                isSelected: isSelected,
                registry: registry,
                registryKey: registry.getKey('reserve', index, card.cardId),
                isPlaceholder: isPlaceholder,
                onTap: () => onCardTap(card.cardId, index),
              );
            },
          ),
        ),
      ],
    );
  }
}
