import 'package:hive/hive.dart';
import 'user_card.dart';
import 'player_deck.dart';

class PlayerProfile extends HiveObject {
  int coins;
  int rubies;
  int runes;
  int xp;
  int trophies;
  String nickname;
  String country;
  int level;
  int currentArenaId;
  String avatarId; // ID do avatar selecionado
  bool isMuted;

  List<UserCard> userCards;
  List<PlayerDeck> decks;

  // Backward compatibility getters
  Map<String, int> get cardLevels => {for (var c in userCards) c.cardId: c.level};
  List<String> get currentDeck => decks.firstWhere((d) => d.isActive, orElse: () => PlayerDeck(id: 'temp', name: 'Temp', cardIds: [])).cardIds;

  // Setter for currentDeck to maintain compatibility with existing code that might set it
  set currentDeck(List<String> newDeck) {
    // Find active deck or create one
    try {
      final active = decks.firstWhere((d) => d.isActive);
      active.cardIds = newDeck;
    } catch (e) {
      decks.add(PlayerDeck(id: 'default', name: 'Deck 1', cardIds: newDeck, isActive: true));
    }
  }

  PlayerProfile({
    this.coins = 1000,
    this.rubies = 100,
    this.runes = 0,
    this.xp = 0,
    this.trophies = 0,
    this.nickname = 'Player',
    this.country = 'Unknown',
    this.level = 1,
    this.currentArenaId = 1,
    this.isMuted = false,
    this.avatarId = 'warrior_m',
    List<UserCard>? userCards,
    List<PlayerDeck>? decks,
  }) : userCards = userCards ?? [],
       decks = decks ?? [];
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
      rubies: fields[1] as int,
      xp: fields[2] as int,
      // Field 3 (cardLevels) and 4 (currentDeck) are deprecated in storage but we might need to handle migration if we cared about old data.
      // For now, we assume new structure or default.
      trophies: fields[5] as int? ?? 0,
      nickname: fields[6] as String? ?? 'Player',
      country: fields[7] as String? ?? 'Unknown',
      level: fields[8] as int? ?? 1,
      runes: fields[9] as int? ?? 0,
      currentArenaId: fields[10] as int? ?? 1,
      userCards: (fields[11] as List?)?.cast<UserCard>() ?? [],
      decks: (fields[12] as List?)?.cast<PlayerDeck>() ?? [],
      isMuted: fields[13] as bool? ?? false,
      avatarId: fields[14] as String? ?? 'warrior_m',
    );
  }

  @override
  void write(BinaryWriter writer, PlayerProfile obj) {
    writer
      ..writeByte(13) // Total fields
      ..writeByte(0)
      ..write(obj.coins)
      ..writeByte(1)
      ..write(obj.rubies)
      ..writeByte(2)
      ..write(obj.xp)
      // Skip 3 and 4 (legacy)
      ..writeByte(5)
      ..write(obj.trophies)
      ..writeByte(6)
      ..write(obj.nickname)
      ..writeByte(7)
      ..write(obj.country)
      ..writeByte(8)
      ..write(obj.level)
      ..writeByte(9)
      ..write(obj.runes)
      ..writeByte(10)
      ..write(obj.currentArenaId)
      ..writeByte(11)
      ..write(obj.userCards)
      ..writeByte(12)
      ..write(obj.decks)
      ..writeByte(13)
      ..write(obj.isMuted)
      ..writeByte(14)
      ..write(obj.avatarId);
  }
}
