part of citadel_server;

void buildPlayer() {
  var entity = new Entity();
  entity.attach(new Component('position', { 'x': 0, 'y': 0 }));
  entity.attach(new Component('velocity', { 'x': 0, 'y': 0 }));

  liveEntities.add(entity);
}