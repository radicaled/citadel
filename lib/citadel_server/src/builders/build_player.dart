part of citadel_server;

Entity buildPlayer() {
  var entity = new Entity();
  entity.attach(new Position(0, 0));
  entity.attach(new Velocity(0, 0));
  entity.attach(new Collidable());

  liveEntities.add(entity);
  return entity;
}