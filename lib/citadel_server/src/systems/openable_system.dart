part of citadel_server;

class OpenableSystem extends EntitySystem {
  filter(entities) => entities.where((e) => e.has([Openable]));

  process(Entity entity) {
    workOn(entity);
  }

  void workOn(Entity entity) {
    Openable o = entity[Openable];
    if (o.isTransitioning) {
      o.transition();
    }
  }
}
