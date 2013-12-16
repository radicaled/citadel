part of citadel_server;

// The collision system checks whether a collision will happen next tick.
// If a collision is about to occur, we...
// set velocity to 0.
void collisionSystem() {
  var filtered = entitiesWithComponents(['position', 'solid', 'velocity']);
  // TODO: velocity is currently +1 per tick.
  // TODO: need to account for different velocity.
  filtered.forEach( (entity) {
    var pos = entity['position'];
    var vel = entity['velocity'];

    var x = pos['x'] + vel['x'];
    var y = pos['y'] + vel['y'];

    // Do any other solid components (moving or not) collide with this one?
    // If so, cease their velocity immediately.
    var collidables = entitiesWithComponents(['position', 'solid'])
      .where( (otherEntity) => otherEntity != entity);

    if (collidables.any( (otherEntity) {
      var pos = otherEntity['position'];
      return pos['x'] == x && pos['y'] == y;

    })) {
      vel['x'] = 0;
      vel['y'] = 0;
    }

  });


}