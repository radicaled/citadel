// Various utility methods relating to entities
part of citadel_server;

Iterable<Entity> entitiesWithComponents(List<Type> names) {
  return liveEntities.where( (entity) => entity.has(names) );
}

// Attempt to locate an entity by its entityId
// Returns null if entityId not found.
Entity findEntity(int entityId) {
  if (entityId == null) return null;
  return liveEntities.firstWhere((e) => e.id == entityId, orElse: () => null);
}