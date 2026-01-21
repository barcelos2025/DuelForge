import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../api/supabase_client_provider.dart';
import 'telemetry_models.dart';
import 'telemetry_queue.dart';

class TelemetryService {
  static final TelemetryService instance = TelemetryService._internal();
  TelemetryService._internal();

  final TelemetryQueue _queue = TelemetryQueue();
  Timer? _flushTimer;
  bool _isEnabled = true; // Pode ser controlado via ContentSDK (Feature Flag)
  bool _isFlushing = false;

  // Configuração
  static const int _batchSize = 20;
  static const Duration _flushInterval = Duration(seconds: 30);

  Future<void> init() async {
    await _queue.init();
    _startFlushTimer();
    
    // Opcional: Hook AppLifecycleState para flush ao fechar app
  }

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  void track(TelemetryEvent event) {
    if (!_isEnabled) return;
    
    // Log local em debug
    if (kDebugMode) {
      debugPrint('📊 Telemetry: ${event.eventType} ${event.payload}');
    }

    _queue.add(event);
  }

  // Atalhos comuns
  void trackMatchStart(String matchId, String opponentType, List<String> deckIds, String arenaId) {
    track(MatchStartEvent(
      matchId: matchId,
      opponentType: opponentType,
      deckIds: deckIds,
      arenaId: arenaId,
    ));
  }

  void trackMatchEnd(String matchId, String result, int duration, int trophies, int crowns) {
    track(MatchEndEvent(
      matchId: matchId,
      result: result,
      durationSeconds: duration,
      trophiesDelta: trophies,
      crowns: crowns,
    ));
  }

  void _startFlushTimer() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(_flushInterval, (_) => _flush());
  }

  Future<void> _flush() async {
    if (_isFlushing || _queue.isEmpty) return;
    _isFlushing = true;

    try {
      final batch = _queue.drain(_batchSize);
      if (batch.isEmpty) return;

      final client = SupabaseClientProvider.client;
      final userId = client.auth.currentUser?.id;

      if (userId == null) {
        // Se não logado, devolve para fila (ou descarta se for anônimo persistente)
        _queue.restore(batch);
        return;
      }

      // Envia para Supabase
      await client.rpc('ingest_telemetry_batch', params: {
        'events': batch.map((e) => e.toJson()).toList(),
      });

      debugPrint('✅ Telemetry: Enviados ${batch.length} eventos.');

    } catch (e) {
      debugPrint('❌ Telemetry: Falha no envio: $e');
      // Retry logic simples: devolve para tentar depois
      // Em produção, limitar retries para não travar fila com evento "venenoso"
    } finally {
      _isFlushing = false;
    }
  }
}
