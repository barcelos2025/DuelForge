import 'package:flutter/material.dart';
import '../../domain/deck_types.dart';
import 'deck_card_widget.dart';
import '../anim/card_rect_registry.dart';

class DeckSlots extends StatelessWidget {
  final List<String> currentDeck;
  final SelectedCardRef? selectedRef;
  final Function(String, int) onCardTap;
  final CardRectRegistry registry;
  final bool isSwapping;
  final SelectedCardRef? swappingSource;
  final SelectedCardRef? swappingTarget;

  const DeckSlots({
    super.key,
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF131B26).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyan.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
          BoxShadow(
            color: Colors.cyan.withOpacity(0.1),
            offset: const Offset(0, -1), // Highlight top
            blurRadius: 2,
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.75,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 8,
        itemBuilder: (context, index) {
          final cardId = index < currentDeck.length ? currentDeck[index] : null;
          final isSelected = selectedRef?.side == DeckSide.game && selectedRef?.index == index;
          
          final isPlaceholder = isSwapping && 
              ((swappingSource?.side == DeckSide.game && swappingSource?.index == index) ||
               (swappingTarget?.side == DeckSide.game && swappingTarget?.index == index));

          return DeckCardWidget(
            cardId: cardId,
            isSelected: isSelected,
            registry: registry,
            registryKey: cardId != null ? registry.getKey('game', index, cardId) : null,
            isPlaceholder: isPlaceholder,
            onTap: () {
              if (cardId != null) {
                onCardTap(cardId, index);
              }
            },
          );
        },
      ),
    );
  }
}
