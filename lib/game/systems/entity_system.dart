part of systems;

abstract class EntitySystem {
  Iterable<Entity> filter(Iterable<Entity> entities);
  void process(Entity entity);

  /// Filter a list of entities via [filter] and then apply the result to [process].
  void processEntities(Iterable<Entity> entities) {
    filter(entities).forEach(process);
  }
}
