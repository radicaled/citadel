part of components;

class Container extends Component with StateMachine {
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
  Container(String state) { currentState = state; }
}