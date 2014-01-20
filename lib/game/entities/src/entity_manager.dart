part of entities;

class EntityManager {
  static StreamController<Entity> _onChangeController = new StreamController.broadcast();
  static Stream<Entity> onChange = _onChangeController.stream;


  static changed(Entity entity) {
    _onChangeController.add(entity);
  }

}