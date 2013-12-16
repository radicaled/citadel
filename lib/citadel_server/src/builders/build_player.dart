part of citadel_server;

Entity buildPlayer() {
  var entity = new Entity();
  entity.attach(new Component('position', { 'x': 0, 'y': 0 }));
  entity.attach(new Component('velocity', { 'x': 0, 'y': 0 }));
  entity.attach(new Component('solid'));

  liveEntities.add(entity);
  return entity;
}