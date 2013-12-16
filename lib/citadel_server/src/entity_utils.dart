// Various utility methods relating to entities
part of citadel_server;

List<Entity> entitiesWithComponents(List<String> names) {
  return liveEntities.where( (entity) => entity.has(names) );
}