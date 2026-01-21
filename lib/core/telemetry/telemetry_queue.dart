import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'telemetry_models.dart';

class TelemetryQueue {
  static const String _storageKey = 'telemetry_queue_v1';
  final Queue<TelemetryEvent> _queue = Queue();
  
  // Limite de segurança para não explodir memória/disco
  static const int _maxQueueSize = 1000;

  Future<void> init() async {
    await _loadFromDisk();
  }

  void add(TelemetryEvent event) {
    if (_queue.length >= _maxQueueSize) {
      // Descarta eventos mais antigos se fila cheia (Drop Head)
      _queue.removeFirst();
    }
    _queue.add(event);
    _saveToDisk(); // Otimização: poderia salvar em batch ou throttle
  }

  List<TelemetryEvent> drain(int count) {
    final List<TelemetryEvent> batch = [];
    while (batch.length < count && _queue.isNotEmpty) {
      batch.add(_queue.removeFirst());
    }
    _saveToDisk();
    return batch;
  }

  void restore(List<TelemetryEvent> events) {
    // Se falhar o envio, devolve para o início da fila
    for (var event in events.reversed) {
      _queue.addFirst(event);
    }
    _saveToDisk();
  }

  bool get isEmpty => _queue.isEmpty;
  int get length => _queue.length;

  Future<void> _saveToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> serialized = _queue.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList(_storageKey, serialized);
    } catch (e) {
      debugPrint('⚠️ TelemetryQueue: Erro ao salvar em disco: $e');
    }
  }

  Future<void> _loadFromDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? serialized = prefs.getStringList(_storageKey);
      
      if (serialized != null) {
        _queue.clear();
        for (var s in serialized) {
          final json = jsonDecode(s);
          _queue.add(TelemetryEvent(
            eventType: json['event_type'],
            payload: json['payload'],
            timestamp: DateTime.parse(json['timestamp']),
          ));
        }
      }
    } catch (e) {
      debugPrint('⚠️ TelemetryQueue: Erro ao carregar do disco: $e');
      // Se corrompido, limpa
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    }
  }
}
