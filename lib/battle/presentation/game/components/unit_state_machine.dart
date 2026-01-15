enum UnitState {
  idle,
  walk,
  attack,
  hit,
  death,
  cast,
  spawn,
}

class UnitStateMachine {
  UnitState _currentState = UnitState.idle;
  UnitState get currentState => _currentState;

  // Simple transition logic
  // Returns true if transition was successful
  bool transitionTo(UnitState newState) {
    if (_currentState == UnitState.death) {
      return false; // Cannot transition out of death
    }

    if (_currentState == newState) return false;

    _currentState = newState;
    return true;
  }
  
  void forceState(UnitState state) {
    _currentState = state;
  }
}
