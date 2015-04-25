part of entities;

typedef void EntityScript(Entity entity);

class Entity extends Events {
  Map<Type, Component> components = new Map<Type, Component>();
  Map<Type, Behavior> behaviors = new Map();
  Map<String, EntityInteraction> reactions = new Map();
  Map<String, EntityScript> scripts = new Map();

  List<String> animationBuffer = [];

  int id;
  final String entityType;

  Entity(this.entityType);

  void attachComponent(Component component) {
    components[component.runtimeType] = component;
  }

  Component detachComponent(Type componentType) {
    return components.remove(componentType);
  }

  void attachBehavior(Behavior behavior) {
    behaviors[behavior.runtimeType] = behavior;
  }

  Behavior detachBehavior(Type behaviorType) {
    return behaviors.remove(behaviorType);
  }

  receive(message, entity, {orElse()}) {
    emit(message, entity);
    // TODO: kind of rough.
    if (!behaviors.values.any((b) => b.triggers.contains(message)) && orElse != null)
      orElse();
  }

  /**
   * Adds an animation to the current entity's animation buffer.
   */
  void animate(String name) {
    animationBuffer.add(name);
  }

  // TODO: can optimize this.
  bool has(List<Type> types) {
    if (components.length == 0) { return false; }
    return types.every( (type) => components.containsKey(type) );
  }

  void use(Type type, void f(Component component)) {
    if (has([type])) { f(this[type]); }
  }

  void require(Type type) {
    if (!has([type])) { throw 'Required component ($type) not found.'; }
  }

  Component operator [](Type componentType) {
    return components[componentType];
  }

  bool operator ==(Entity other) {
    if (other == null) return false;
    return this.id == other.id;
  }

  int get hashCode =>
    hashObjects([id]);
}
