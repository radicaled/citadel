// Various utility methods relating to entities
part of citadel_server;

Iterable<Entity> entitiesWithComponents(List<Type> names) {
  return liveEntities.where( (entity) => entity.has(names) );
}