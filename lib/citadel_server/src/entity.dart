part of citadel_server;

class Entity {
  int mask;
  List<Component> components;

  void attach(Component component) {
    components.add(component);
    mask |= component.mask;
  }

  // TODO: can optimize this.
  bool has(List<String> componentNames) {
    if (components.length == 0) { return false; }
    names = components.map( (component) => component.name);
    return componentNames.every( (name) => names.contains(name) );
  }
}