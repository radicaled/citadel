part of citadel_server;

openableSystem() {
  new OpenableSystem().execute();
}

class OpenableSystem {

  void execute() {
    entitiesWithComponents([Openable]).forEach((e) => workOn(e));
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
      EntityManager.addMessage(entity, o.currentState);
    }
  }
}