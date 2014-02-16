part of citadel_server;

containerSystem() {
  new ContainerSystem().execute();
}

class ContainerSystem {
  // FIXME
  bool stateChange;
  void execute() {
    entitiesWithComponents([Container]).forEach((e) => workOn(e));
  }

  void workOn(Entity entity) {
    // FIXME
    stateChange = false;
    _animate(entity);
    _finalizeState(entity);
    _showOrHideContents(entity);
  }

  void _animate(Entity entity) {
    // FIXME: >:(
    Container c = entity[Container];
    // Inbetween open / closed states.
    if (!c.isOpen && !c.isClosed) {
      entity.animate(c.currentState);
    }
  }

  void _finalizeState(Entity entity) {
    // FIXME: state machine?
    Container c = entity[Container];
    if ([Container.CLOSING, Container.OPENING].contains(c.currentState)) {
      c.transition();
      stateChange = true;
    }
  }

  // FIXME: sync with animation
  void _showOrHideContents(Entity entity) {
    if (!stateChange) return;
    var c = entity[Container];
    var p = entity[Position];
    // FIXME: I need a way to filter out special "hidden" entities.
    // EG, atmospherics may be invisible entities that are on a higher z-plane than the locker.
    var entities = entitiesWithComponents([Position]).where((e) => e[Position].isSame2d(p) && e[Position] > p );
    // TODO: should I use a 'Visible' component instead?
    if (c.isOpen) {
      entities.forEach((e) => e.attach(new Visible()));
      entities.forEach((e) => EntityManager.created(e));
    } else if (c.isClosed) {
      entities.forEach((e) => e.detach(Visible));
      entities.forEach((e) => EntityManager.hidden(e));
    }
  }
}