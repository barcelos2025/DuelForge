
import 'dart:async';

import '../config/battle_tuning.dart';

class PowerService {
  static const double maxPower = 10.0;

  double _currentPower;
  bool _isOvertime;
  
  final StreamController<double> _powerController = StreamController<double>.broadcast();
  Stream<double> get powerStream => _powerController.stream;

  PowerService({double initialPower = 5.0}) 
      : _currentPower = initialPower,
        _isOvertime = false;

  double get currentPower => _currentPower;

  void setOvertime(bool active) {
    _isOvertime = active;
  }

  void tick(double dt, double timeElapsed, double matchDuration) {
    if (_currentPower >= maxPower) return;

    // Calculate dynamic regeneration rate
    // Start: 3.0s per elixir => 1/3 = 0.33 elixir/s
    // End: 1.0s per elixir => 1/1 = 1.0 elixir/s
    
    double currentRate;
    
    if (_isOvertime) {
      currentRate = 2.0; // Overtime: 0.5s per elixir (2.0 elixir/s) - Fixed fast rate
    } else {
      // Linear interpolation based on match progress
      final progress = (timeElapsed / matchDuration).clamp(0.0, 1.0);
      const startRate = 0.333; // 1 elixir per 3s
      const endRate = 1.0;     // 1 elixir per 1s
      
      currentRate = startRate + (endRate - startRate) * progress;
    }

    _currentPower += currentRate * dt;
    
    if (_currentPower > maxPower) {
      _currentPower = maxPower;
    }
    
    _powerController.add(_currentPower);
  }

  bool consume(int cost) {
    if (BattleTuning.debugInfinitePower) return true;

    if (_currentPower >= cost) {
      print('⚡ PowerService: Consuming $cost. Old: $_currentPower');
      _currentPower -= cost;
      print('⚡ PowerService: New: $_currentPower');
      _powerController.add(_currentPower);
      return true;
    }
    print('⚡ PowerService: Failed to consume $cost. Current: $_currentPower');
    return false;
  }

  bool canConsume(int cost) => BattleTuning.debugInfinitePower || _currentPower >= cost;

  void dispose() {
    _powerController.close();
  }
}
