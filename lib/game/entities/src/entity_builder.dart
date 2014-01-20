part of entities;

abstract class EntityBuilder {
  var _entity;
  _setup();

  Entity build() {
    _entity = new Entity();
    _setup();
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

  void reaction(String name, EntityInteraction reaction) {
    _entity.reactions[name] = reaction;
  }

  void behavior(String name, setup(EntityBehavior b)) {
    _entity.behaviors[name] = (thisEntity, thatEntity) {
      var behavior = new EntityBehavior(name, thisEntity, thatEntity);
      setup(behavior);
      behavior.perform();
    };
  }
}