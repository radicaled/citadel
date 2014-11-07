part of citadel_server;

class OpenableSystem extends EntitySystem {
  filter(entities) => entities.where((e) => e.has([Openable]));

  process(Entity entity) {
    workOn(entity);
  }

  void workOn(Entity entity) {
    _animate(entity);
    _finalizeState(entity);
  }

  void _animate(Entity entity) {
    Openable o = entity[Openable];
    // Inbetween open / closed states.
    if (o.isTransitioning) {
      entity.animate(o.currentState);
    }
  }

  void _finalizeState(Entity entity) {
    Openable o = entity[Openable];
    if (o.isTransitioning) {
      o.transition();
    }
  }
}
