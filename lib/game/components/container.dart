part of components;

class Container extends Component {
  static const OPENING = "opening";
  static const CLOSING = "closing";
  static const OPENED = "opened";
  static const CLOSED = "closed";

  String state;

  bool get isOpen => state == OPENED;
  bool get isClosed => state == CLOSED;
  Container([this.state]);
}