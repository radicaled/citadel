part of entities;

abstract class EntitySystem {
  Iterable<Entity> filter(Iterable<Entity> entities);
  void process(Entity entity);

  /// Filter a list of entities via [filter] and then apply the result to [process].
  void processEntities(List<Entity> entities) {
    filter(entities).forEach(process);
  }
}
