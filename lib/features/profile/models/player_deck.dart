import 'package:hive/hive.dart';

class PlayerDeck {
  String id;
  String name;
  List<String> cardIds;
  bool isActive;

  PlayerDeck({
    required this.id,
    required this.name,
    required this.cardIds,
    this.isActive = false,
  });

  factory PlayerDeck.fromJson(Map<String, dynamic> json) {
    return PlayerDeck(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Deck',
      cardIds: (json['cards'] as List<dynamic>?)?.cast<String>() ?? [],
      isActive: json['is_active'] ?? false,
    );
  }
}

class PlayerDeckAdapter extends TypeAdapter<PlayerDeck> {
  @override
  final int typeId = 2; // Unique ID

  @override
  PlayerDeck read(BinaryReader reader) {
    return PlayerDeck(
      id: reader.readString(),
      name: reader.readString(),
      cardIds: reader.readStringList(),
      isActive: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, PlayerDeck obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeStringList(obj.cardIds);
    writer.writeBool(obj.isActive);
  }
}
