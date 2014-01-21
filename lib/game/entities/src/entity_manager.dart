part of entities;

class EntityManager {
  static StreamController<EntityEvent> _entityEventController = new StreamController.broadcast();
  static var onChanged = _subscribe('changed');
  static var onHidden = _subscribe('hidden');


  static changed(Entity entity) {
    _signal('changed', entity);
  }

  static hidden(Entity entity) {
    _signal('hidden', entity);
  }

  static Stream<EntityEvent> _subscribe(String name) {
    return _entityEventController.stream.where((entityEvent) => entityEvent.name == name);
  }

  static _signal(String name, Entity entity) {
    _entityEventController.add(new EntityEvent(name, entity));
  }

}