part of citadel_server;

void movementSystem(List<Entity> entities) {
  var matching = entities.where( (entity) { entity.has(['position', 'velocity']); } );
  log.info('Found matching entities: $matching');

}