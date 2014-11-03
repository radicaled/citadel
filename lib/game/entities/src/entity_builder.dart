part of entities;

abstract class EntityBuilder {
  var _entity;
  setup();

  Entity build(String entityType) {
    _entity = new Entity(entityType);
    setup();
    return _entity;
  }

  // DSL-style helper methods
  void has(componentType, [List constructorParameters]) {
    if (constructorParameters == null) constructorParameters = [];
    _entity.attach(reflectClass(componentType).newInstance(new Symbol(''), constructorParameters).reflectee);
    // Did an exception occurr here? If so, make sure the component has a parameterless (or optional parameter) constructor.
    // PS: I removed a try-catch block that printed a helpful debug message because it added several lines and
    // made the method 'unreadable.'
  }

  void reaction(String name, react(EntityInteraction ei)) {
    _entity.reactions[name] = react;
  }

  /**
   * Scripts only modify the current entity.
   */
  void script(String name, EntityScript es) {
    _entity.scripts[name] = es;
  }

  void behavior(String name, setup(EntityBehavior b)) {
    _entity.behaviors[name] = (thisEntity, thatEntity, invokingEntity) {
      var behavior = new EntityBehavior(name, thisEntity, thatEntity, invokingEntity);
      setup(behavior);
      behavior.perform();
    };
  }
}
