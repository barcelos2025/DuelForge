/// Conteúdo padrão mínimo para garantir que o jogo não quebre se offline e sem cache.
class ContentDefaults {
  static const String cardCatalog = '''
[
  {"id": "archer", "rarity": "common", "cost": 3, "name": "Arqueira"},
  {"id": "knight", "rarity": "rare", "cost": 4, "name": "Cavaleiro"}
]
''';

  static const String balance = '''
{
  "global_damage_mult": 1.0,
  "global_hp_mult": 1.0
}
''';

  static const String shop = '''
{
  "daily_refresh_hour_utc": 0,
  "slots": 3
}
''';

  static const String dropTables = '''
{
  "chests": ["wooden"]
}
''';

  static Map<String, String> get all => {
    'card_catalog': cardCatalog,
    'balance': balance,
    'shop': shop,
    'drop_tables': dropTables,
  };
}
