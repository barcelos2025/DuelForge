import 'package:hive/hive.dart';

class UserCard {
  String cardId;
  int level;
  int fragments;
  bool isObtained;

  UserCard({
    required this.cardId,
    this.level = 1,
    this.fragments = 0,
    this.isObtained = false,
  });

  factory UserCard.fromJson(Map<String, dynamic> json) {
    return UserCard(
      cardId: json['card_id'] ?? '',
      level: json['level'] ?? 1,
      fragments: json['fragments'] ?? 0,
      isObtained: json['is_obtained'] ?? false,
    );
  }
}

class UserCardAdapter extends TypeAdapter<UserCard> {
  @override
  final int typeId = 1; // Unique ID

  @override
  UserCard read(BinaryReader reader) {
    return UserCard(
      cardId: reader.readString(),
      level: reader.readInt(),
      fragments: reader.readInt(),
      isObtained: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, UserCard obj) {
    writer.writeString(obj.cardId);
    writer.writeInt(obj.level);
    writer.writeInt(obj.fragments);
    writer.writeBool(obj.isObtained);
  }
}
