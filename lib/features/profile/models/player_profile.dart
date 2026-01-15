
import 'package:hive/hive.dart';

class PlayerProfile extends HiveObject {
  int coins;
  int gems;
  int xp;
  Map<String, int> cardLevels;
  List<String> currentDeck;

  PlayerProfile({
    this.coins = 1000,
    this.gems = 100,
    this.xp = 0,
    Map<String, int>? cardLevels,
    List<String>? currentDeck,
  }) : cardLevels = cardLevels ?? {},
       currentDeck = currentDeck ?? [];
}

class PlayerProfileAdapter extends TypeAdapter<PlayerProfile> {
  @override
  final int typeId = 0;

  @override
  PlayerProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayerProfile(
      coins: fields[0] as int,
      gems: fields[1] as int,
      xp: fields[2] as int,
      cardLevels: (fields[3] as Map).cast<String, int>(),
      currentDeck: (fields[4] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, PlayerProfile obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.coins)
      ..writeByte(1)
      ..write(obj.gems)
      ..writeByte(2)
      ..write(obj.xp)
      ..writeByte(3)
      ..write(obj.cardLevels)
      ..writeByte(4)
      ..write(obj.currentDeck);
  }
}
