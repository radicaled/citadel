// Various utility methods relating to entities
part of citadel_server;

Iterable<Entity> entitiesWithComponents(List<Type> names) {
  return world.entities.where( (entity) => entity.has(names) );
}

// Attempt to locate an entity by its entityId
// Returns null if entityId not found.
Entity findEntity(int entityId) {
  if (entityId == null) return null;
  return world.entities.firstWhere((e) => e.id == entityId, orElse: () => null);
}

Iterable<Entity> entitiesWith(List<Type> components, {String message}) {
  if (message != null) {
    return EntityManager.withMessage(message).where((entity) => entity.has(components));
  } else {
    return entitiesWithComponents(components);
  }
}
