part of citadel_server;

containerSystem() {
  new ContainerSystem().execute();
}

class ContainerSystem {
  void execute() {
    entitiesWith([Openable, Container], message: Openable.OPENED).forEach((e) => showContents(e));
    entitiesWith([Openable, Container], message: Openable.CLOSED).forEach((e) => hideContents(e));
  }

  // FIXME: sync with animation
  void showContents(Entity entity) {
    var p = entity[Position];
    var entities = _nearbyEntities(p);
    entities.forEach((e) => e.attach(new Visible()));
    entities.forEach((e) => EntityManager.created(e));
  }

  // FIXME: sync with animation
  void hideContents(Entity entity) {
    var p = entity[Position];
    var entities = _nearbyEntities(p);
    entities.forEach((e) => e.detach(Visible));
    entities.forEach((e) => EntityManager.hidden(e));
  }

  _nearbyEntities(Position pos) {
    // FIXME: I need a way to filter out special "hidden" entities.
    // EG, atmospherics may be invisible entities that are on a higher z-plane than the locker.
    return entitiesWithComponents([Position]).where((e) => e[Position].isSame2d(pos) && e[Position] > pos );
  }
}
