part of citadel_server;

void movementSystem(List<Entity> entities) {
  var matching = entities.where( (entity) => entity.has(['position', 'velocity']) );
  log.info('Found matching entities: $matching');

  matching.forEach( (entity) {
    var pos = entity['position'];
    var vel = entity['velocity'];

    if (vel['x'] != 0 || vel['y'] != 0) {

      pos['x'] += vel['x'];
      pos['y'] += vel['y'];

      vel['x'] = 0;
      vel['y'] = 0;

      commandQueue.add({'name': 'moveTo', 'payload': { 'x': pos['x'], 'y': pos['y'] } });
    }
  });

}