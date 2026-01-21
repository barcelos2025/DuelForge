import 'package:flutter/material.dart';

class PlayerCardModel {
  final String id;
  final String name;
  final String rarity; // 'common', 'rare', 'epic', 'legendary'
  final int level;
  final int fragmentsOwned;
  final int fragmentsRequiredNext;
  final bool isObtained;
  final String assetPath;
  final int elixirCost;

  PlayerCardModel({
    required this.id,
    required this.name,
    required this.rarity,
    required this.level,
    required this.fragmentsOwned,
    required this.fragmentsRequiredNext,
    required this.isObtained,
    required this.assetPath,
    required this.elixirCost,
  });

  bool get canUpgrade => isObtained && fragmentsOwned >= fragmentsRequiredNext;
}
