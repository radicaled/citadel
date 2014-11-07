part of citadel_server;

// The collision system checks whether a collision will happen next tick.
// If a collision is about to occur, we...
// set velocity to 0.
// TODO: super naive system.
class CollisionSystem extends EntitySystem {
  Iterable<Entity> filter(Iterable<Entity> entities) =>
    entities.where((e) => e.has([Position, Velocity]));

  void process(Entity entity) {
    var pos = entity[Position];
    var vel = entity[Velocity];

    var expectedPosition = new Position(pos.x + vel.x, pos.y + vel.y);

    // Do any other solid components (moving or not) collide with this one?
    // If so, cease their velocity immediately.
    var collidables = entitiesWithComponents([Position, Collidable]).where((e) => e.id != entity.id);
    var collidingEntity = collidables.firstWhere((oe) => oe[Position].isSame2d(expectedPosition), orElse: () => null);

    if (collidingEntity != null) {
      collidingEntity.react('collide', entity, null);
      vel.halt();
    }
  }
}
