part of citadel_server;

// The collision system checks whether a collision will happen next tick.
// If a collision is about to occur, we...
// set velocity to 0.
// TODO: super naive system.
void collisionSystem() {
  var filtered = entitiesWithComponents([Position, Collidable, Velocity]);
  // TODO: velocity is currently -1 per tick.
  // TODO: need to account for different velocity.
  filtered.forEach( (entity) {
    var pos = entity[Position];
    var vel = entity[Velocity];

    var expectedPosition = new Position(pos.x + vel.x, pos.y + vel.y);

    // Do any other solid components (moving or not) collide with this one?
    // If so, cease their velocity immediately.
    var collidables = entitiesWithComponents([Position, Collidable]);
    var collidingEntity = collidables.firstWhere((oe) => oe[Position] == expectedPosition, orElse: () => null);

    if (collidingEntity != null) {
      collidingEntity.react('collide', entity);
      vel.halt();
    }
  });
}