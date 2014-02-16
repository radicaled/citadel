library state_machine;


abstract class StateMachine {
  String _currentState;

  String get currentState => _currentState;
  void set currentState (state) => transitionTo(state);

  final STATE_MAP = {};

  /**
   * Transition this component from one state to the next.
   */
  String transition() {
    _stateCheck(currentState);
    return _currentState = STATE_MAP[currentState];
  }

  /**
   * Transition this component to an arbitrary state.
   */
  void transitionTo(String state) {
    _stateCheck(state);
    _currentState = state;
  }

  void _stateCheck(String state) {
    if (!STATE_MAP.keys.contains(state)) throw new ArgumentError("State $state not present in Component's STATE_MAP!");
  }
}