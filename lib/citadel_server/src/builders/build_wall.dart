part of citadel_server;

Entity buildWall(x, y, tileGid) {
  var entity = new Entity();

  entity.attach(new Position(x, y));
  entity.attach(new Collidable());
  entity.attach(new TileGraphics([tileGid]));
  liveEntities.add(entity);
  return entity;
}