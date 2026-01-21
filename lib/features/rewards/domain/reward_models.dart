
enum RewardType { currency, card_fragment, card_part, chest, unknown }

class RewardItem {
  final String id; // ID da entrada no outbox
  final RewardType type;
  final String resourceId; // 'gold', 'runes', 'card_id', etc.
  final int amount;
  final String? source; // 'chest', 'battle', etc.

  const RewardItem({
    required this.id,
    required this.type,
    required this.resourceId,
    required this.amount,
    this.source,
  });

  factory RewardItem.fromJson(Map<String, dynamic> json, String outboxId) {
    final typeStr = json['type'] as String? ?? 'unknown';
    RewardType type;
    String resId = json['id'] ?? json['card_id'] ?? 'unknown';

    switch (typeStr) {
      case 'currency': type = RewardType.currency; break;
      case 'card_fragment': type = RewardType.card_fragment; break;
      case 'card_part': type = RewardType.card_part; break;
      case 'chest': type = RewardType.chest; break; // Se o payload vier diferente
      default: type = RewardType.unknown;
    }

    return RewardItem(
      id: outboxId,
      type: type,
      resourceId: resId,
      amount: (json['amount'] as num?)?.toInt() ?? 1,
      source: json['source'],
    );
  }
}

class RewardBatch {
  final List<String> outboxIds;
  final List<RewardItem> items;
  final String sourceId;

  RewardBatch({
    required this.outboxIds, 
    required this.items,
    this.sourceId = '',
  });
}
