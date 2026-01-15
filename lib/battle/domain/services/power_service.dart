
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

  void tick(double dt) {
    if (_currentPower >= maxPower) return;

    final rate = _isOvertime ? BattleTuning.elixirRegenOvertime : BattleTuning.elixirRegenBase;
    _currentPower += rate * dt;
    
    if (_currentPower > maxPower) {
      _currentPower = maxPower;
    }
    
    _powerController.add(_currentPower);
  }

  bool consume(int cost) {
    if (BattleTuning.debugInfinitePower) return true;

    if (_currentPower >= cost) {
      _currentPower -= cost;
      _powerController.add(_currentPower);
      return true;
    }
    return false;
  }

  bool canConsume(int cost) => BattleTuning.debugInfinitePower || _currentPower >= cost;

  void dispose() {
    _powerController.close();
  }
}
