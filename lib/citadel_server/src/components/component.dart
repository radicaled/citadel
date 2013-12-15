part of citadel_server;

class Component {
  final String name;

  Map attributes = new Map();

  Component(this.name, this.attributes);

  dynamic operator [](attributeName) {
    return attributes[attributeName];
  }

  void operator[]=(attributeName, value) {
    attributes[attributeName] = value;
  }
}