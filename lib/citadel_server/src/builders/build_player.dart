part of citadel_server;

Entity buildPlayer() {
  var entity = new Entity();
  entity.attach(new Position(0, 0));
  entity.attach(new Velocity(0, 0));
  entity.attach(new Collidable());
  entity.attach(new Player());
  /* TODO: remove hardcoding */
  entity.attach(new TileGraphics([2]));
  liveEntities.add(entity);
  return entity;
}