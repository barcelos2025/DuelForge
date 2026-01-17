enum DeckSide { game, reserve }

enum ReserveSortKey { type, rarity, power, level }

enum SortOrder { asc, desc }

class SelectedCardRef {
  final String cardId;
  final DeckSide side;
  final int index;

  SelectedCardRef({
    required this.cardId,
    required this.side,
    required this.index,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectedCardRef &&
          runtimeType == other.runtimeType &&
          cardId == other.cardId &&
          side == other.side &&
          index == other.index;

  @override
  int get hashCode => cardId.hashCode ^ side.hashCode ^ index.hashCode;
}
