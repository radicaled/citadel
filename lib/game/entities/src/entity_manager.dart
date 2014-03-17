part of entities;

class EntityManager {
  static StreamController<EntityEvent> _entityEventController = new StreamController.broadcast();
  static var onChanged = _subscribe('changed');
  static var onHidden = _subscribe('hidden');
  static var onCreated = _subscribe('created');

  static List<EntityMessage> messageQueue = new List();

  static Iterable<Entity> withMessage(String message) {
    return messageQueue.where((em) => em.name == message).map((em) => em.entity);
  }

  static addMessage(Entity e, String message) {
    messageQueue.add(new EntityMessage(message, e));
  }

  static clearMessages() {
   messageQueue.clear();
  }

  static changed(Entity entity) {
    _signal('changed', entity);
  }

  static hidden(Entity entity) {
    _signal('hidden', entity);
  }

  static created(Entity entity) {
    _signal('created', entity);
  }

  static Stream<EntityEvent> _subscribe(String name) {
    return _entityEventController.stream.where((entityEvent) => entityEvent.name == name);
  }

  static _signal(String name, Entity entity) {
    _entityEventController.add(new EntityEvent(name, entity));
  }

}

class EntityMessage {
  String name;
  Entity entity;

  EntityMessage(this.name, this.entity);
}
