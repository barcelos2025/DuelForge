import 'package:flutter/material.dart';

class CardRectRegistry {
  final Map<String, Rect> _rects = {};

  void register(String key, Rect rect) {
    _rects[key] = rect;
  }

  Rect? getRect(String key) => _rects[key];

  String getKey(String side, int index, String cardId) {
    return '${side}_${index}_$cardId';
  }
}
