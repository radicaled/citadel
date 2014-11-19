part of entities;

typedef void EntityScript(Entity entity);

class Entity {
  Map<Type, Component> components = new Map<Type, Component>();
  Map<String, EntityInteraction> behaviors = new Map();
  Map<String, EntityInteraction> reactions = new Map();
  Map<String, EntityScript> scripts = new Map();

  List<String> animationBuffer = [];

  int id;
  final String entityType;

  Entity(this.entityType);

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
  bool react(String name, Entity invokerEntity, Entity withEntity, {orElse()}) {
    var reaction = reactions[name];
    // EntityInteraction(this.current, this.target, this.invoker);
    if (reaction != null) { reaction(new EntityInteraction(this, withEntity, invokerEntity)); }
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
