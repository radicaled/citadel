part of citadel_server;

class ContainerSystem extends EntitySystem {
  Iterable<Entity> filter(Iterable<Entity> entities) =>
    entities.where((e) => e.has([Container]));

  void process(Entity entity) {
    entity.use(Openable, (openable) {
      // This is goddamn bullshit wizardy
      // We use transitioning states to show / hide entities.
      // Need a _much_ better system than that.
      // TODO: need to resolve issues with ContainerSystem relying on Openable.currentState to add / remove visible entities.
      if (openable.isTransitioning) {
        openable.currentState == Openable.OPENING  ? showContents(entity) : hideContents(entity);
      }
    });

    updatePosition(entity);
  }

  void updatePosition(Entity entity) {
    var c = entity[Container];
    var p = entity[Position];
    var entities = c.entityIds.map(findEntity);
    entities.forEach((e) => e.attach(new Position.from(p)));
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
    var o = entity[Openable];
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
