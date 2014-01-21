part of entities;

typedef EntityInteraction(Entity thisEntity, Entity thatEntity);

class Entity {
  Map<Type, Component> components = new Map<Type, Component>();
  Map<String, EntityInteraction> behaviors = new Map();
  Map<String, EntityInteraction> reactions = new Map();
  int id;

  // FIXME: onEmit represents an emit to a specific entity.
  // Therefore, onEmit is an instance member, since not everyone will be interested in knowing that.
  // onEmitNear is an emit to an area by an entity, and lots of people (lots of other entities) will be interested in knowing that.
  // This should be correct..
  StreamController<EmitEvent> _emitController = new StreamController.broadcast();
  Stream<EmitEvent> onEmit;

  static StreamController<EmitEvent> _emitNearController = new StreamController.broadcast();
  static Stream<EmitEvent> onEmitNear = _emitNearController.stream;

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
    _emitController.add(new EmitEvent(this, text));
  }

  void emitNear(String text) {
    _emitNearController.add(new EmitEvent(this, text));
  }
}