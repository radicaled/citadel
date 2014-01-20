part of entities;

typedef EntityInteraction(Entity thisEntity, Entity thatEntity);

class Entity {
  Map<Type, Component> components = new Map<Type, Component>();
  Map<String, EntityInteraction> behaviors = new Map();
  Map<String, EntityInteraction> reactions = new Map();
  int id;

  StreamController<String> _emitController = new StreamController.broadcast();
  Stream<String> onEmit;

  Entity() {
    onEmit = _emitController.stream;
  }

  void attach(Component component) {
    components[component.runtimeType] = component;
  }

  // TODO: can optimize this.
  bool has(List<Type> types) {
    if (components.length == 0) { return false; }
    return types.every( (type) => components.containsKey(type) );
  }

  Component operator [](Type componentType) {
    return components[componentType];
  }

  void emit(String text) {
    _emitController.add(text);
  }
}