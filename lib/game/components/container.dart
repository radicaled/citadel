part of components;

class Container extends Component {
  static const OPENING = "OPENING";
  static const CLOSING = "CLOSING";
  static const OPENED = "OPENED";
  static const CLOSED = "CLOSED";

  String state;

  bool get isOpen => state == OPENED;
  bool get isClosed => state == CLOSED;
  Container([this.state]);
}