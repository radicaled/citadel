part of entities;

typedef EntityBehavior(Entity thisEntity, Entity thatEntity);

class Entity {
  Map<Type, Component> components = new Map<Type, Component>();
  Map<String, EntityBehavior> behaviors = new Map();
  int id;

  Entity();

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
}