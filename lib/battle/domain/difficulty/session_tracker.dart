import 'package:flutter/foundation.dart';

class SessionTracker {
  static final SessionTracker _instance = SessionTracker._internal();
  factory SessionTracker() => _instance;
  SessionTracker._internal();

  DateTime? _lastActivityTime;
  DateTime? _sessionStartTime;
  int _matchesInSession = 0;
  
  // Configuração
  static const int _pauseThresholdMinutes = 60; // Pausa mínima para reset

  /// Registra atividade (início de batalha, interação no menu, etc)
  void registerActivity() {
    final now = DateTime.now();
    
    if (_lastActivityTime != null) {
      final diff = now.difference(_lastActivityTime!).inMinutes;
      if (diff >= _pauseThresholdMinutes) {
        _resetSession();
        debugPrint('🔄 SessionTracker: Sessão resetada após ${diff}min de pausa.');
      }
    } else {
      _resetSession(); // Primeira atividade
    }

    _lastActivityTime = now;
  }

  void registerMatchStart() {
    registerActivity();
    _matchesInSession++;
  }

  void _resetSession() {
    _sessionStartTime = DateTime.now();
    _matchesInSession = 0;
  }

  /// Retorna o tempo contínuo da sessão em minutos
  int get sessionDurationMinutes {
    if (_sessionStartTime == null) return 0;
    return DateTime.now().difference(_sessionStartTime!).inMinutes;
  }

  int get matchesInSession => _matchesInSession;

  // Debug
  void debugForceReset() => _resetSession();
}
