import 'dart:convert';

/// Definição de Carta (Versão simplificada para o SDK)
class CardDef {
  final String id;
  final String rarity;
  final int cost;
  final Map<String, dynamic> extra;

  CardDef({required this.id, required this.rarity, required this.cost, this.extra = const {}});

  factory CardDef.fromJson(Map<String, dynamic> json) {
    return CardDef(
      id: json['id'] ?? 'unknown',
      rarity: json['rarity'] ?? 'common',
      cost: json['cost'] ?? 0,
      extra: json,
    );
  }
}

/// Definição de Loja
class ShopDef {
  final int refreshHour;
  final int slots;
  final Map<String, dynamic> config;

  ShopDef({required this.refreshHour, required this.slots, this.config = const {}});

  factory ShopDef.fromJson(Map<String, dynamic> json) {
    return ShopDef(
      refreshHour: json['daily_refresh_hour_utc'] ?? 0,
      slots: json['slots'] ?? 6,
      config: json,
    );
  }
}

/// Definição de Tabelas de Drop
class DropTableDef {
  final List<String> chests;
  final Map<String, dynamic> tables;

  DropTableDef({required this.chests, required this.tables});

  factory DropTableDef.fromJson(Map<String, dynamic> json) {
    return DropTableDef(
      chests: List<String>.from(json['chests'] ?? []),
      tables: json['tables'] ?? {},
    );
  }
}

/// Definição de Balanceamento
class BalanceDef {
  final double damageMult;
  final double hpMult;

  BalanceDef({required this.damageMult, required this.hpMult});

  factory BalanceDef.fromJson(Map<String, dynamic> json) {
    return BalanceDef(
      damageMult: (json['global_damage_mult'] as num?)?.toDouble() ?? 1.0,
      hpMult: (json['global_hp_mult'] as num?)?.toDouble() ?? 1.0,
    );
  }
}

/// Manifesto de Versão
class ContentManifest {
  final String versionId;
  final String label;
  final Map<String, String> blobs; // blob_type -> checksum

  ContentManifest({required this.versionId, required this.label, required this.blobs});

  factory ContentManifest.fromJson(List<dynamic> rows) {
    if (rows.isEmpty) return ContentManifest(versionId: '', label: 'Empty', blobs: {});
    
    final first = rows.first;
    final versionId = first['version_id'] ?? '';
    final label = first['version_label'] ?? '';
    
    final Map<String, String> blobs = {};
    for (var row in rows) {
      blobs[row['blob_type']] = row['checksum'] ?? '';
    }

    return ContentManifest(versionId: versionId, label: label, blobs: blobs);
  }
}
