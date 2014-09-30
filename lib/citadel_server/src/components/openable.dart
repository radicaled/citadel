part of citadel_server.components;

class Openable extends Component with StateMachine {
  static const OPENING = "opening";
  static const CLOSING = "closing";
  static const OPENED = "opened";
  static const CLOSED = "closed";

  final STATE_MAP = {
    OPENING: OPENED,
    OPENED: CLOSING,
    CLOSING: CLOSED,
    CLOSED: OPENING
  };

  bool get isOpen => currentState == OPENED;
  bool get isClosed => currentState == CLOSED;
  bool get isTransitioning => !isOpen && !isClosed;
  Openable(String state) { currentState = state; }
}