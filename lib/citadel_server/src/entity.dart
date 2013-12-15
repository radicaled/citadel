part of citadel_server;

class Entity {
  Map<String, Component> components = new Map<String, Component>();

  void attach(Component component) {
    components[component.name] = component;
  }

  // TODO: can optimize this.
  bool has(List<String> componentNames) {
    if (components.length == 0) { return false; }
    return componentNames.every( (name) => components.containsKey(name) );
  }

  Component operator [](String componentName) {
    return components[componentName];
  }
}