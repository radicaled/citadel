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
    var c = entity[Container];
    // Inbetween open / closed states.
    if (!c.isOpen && !c.isClosed) {
      entity.animate(c.state);
    }
  }

  void _finalizeState(Entity entity) {
    // FIXME: state machine?
    var c = entity[Container];
    switch(c.state) {
      case Container.CLOSING:
        c.state = Container.CLOSED;
        stateChange = true;
        break;
      case Container.OPENING:
        c.state = Container.OPENED;
        stateChange = true;
        break;
    }
  }

  // FIXME: sync with animation
  void _showOrHideContents(Entity entity) {
    if (!stateChange) return;
    var c = entity[Container];
    var p = entity[Position];
    var entities = liveEntities.where((e) => e.isChild && e.root == entity);
    liveEntities.where((e) => e.root != null).forEach((e) => print("Mine: ${e.id} | Root: ${e.root.id}"));
    // TODO: should I use a 'Visible' component instead?
    if (c.isOpen) {
      entities.forEach((e) => e.attach(new Position.from(p)));
      entities.forEach((e) => EntityManager.created(e));
    } else if (c.isClosed) {
      entities.forEach((e) => e.detach(Position));
      entities.forEach((e) => EntityManager.hidden(e));
    }
  }
}