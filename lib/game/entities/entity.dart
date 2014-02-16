part of entities;

typedef void EntityInteraction(Entity thisEntity, Entity thatEntity);
typedef void EntityScript(Entity entity);

class Entity {
  Map<Type, Component> components = new Map<Type, Component>();
  Map<String, EntityInteraction> behaviors = new Map();
  Map<String, EntityInteraction> reactions = new Map();
  Map<String, EntityScript> scripts = new Map();

  List<String> animationBuffer = [];

  Entity root;
  bool get isChild => root != this;

  int id;
  final String entityType;

  // FIXME: onEmit represents an emit to a specific entity.
  // Therefore, onEmit is an instance member, since not everyone will be interested in knowing that.
  // onEmitNear is an emit to an area by an entity, and lots of people (lots of other entities) will be interested in knowing that.
  // This should be correct..
  StreamController<EmitEvent> _emitController = new StreamController.broadcast();
  Stream<EmitEvent> onEmit;

  static StreamController<EmitEvent> _emitNearController = new StreamController.broadcast();
  static Stream<EmitEvent> onEmitNear = _emitNearController.stream;

  Entity(this.entityType) {
    onEmit = _emitController.stream;
    root = this;
  }

  void attach(Component component) {
    components[component.runtimeType] = component;
  }

  Component detach(Type componentType) {
    return components.remove(componentType);
  }

  /**
   * React to an event [name]. If not found, the optional [orElse] function can be called.
   *
   * Returns true if Entity reacted.
   */
  bool react(String name, Entity instigator, {orElse()}) {
    var reaction = reactions[name];
    if (reaction != null) { reaction(this, instigator); }
    else if (orElse != null) { orElse(); }
    return reaction != null;
  }

  /**
   * Executes a script on this entity.
   *
   * Raises an [ArgumentError] if the script is not present.
   */
  void execute(String scriptName) {
    var script = scripts[scriptName];
    if(script == null) throw new ArgumentError('Script $scriptName is not present on $this!');
    script(this);
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


  Component operator [](Type componentType) {
    return components[componentType];
  }

  void emit(String text) {
    root._emitController.add(new EmitEvent(this, text));
  }

  void emitNear(String text) {
    _emitNearController.add(new EmitEvent(this, text));
  }
}