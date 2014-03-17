part of entities;

class CommandDoor extends EntityBuilder {
  _setup() {
    has(Position);
    has(Collidable);
    has(TileGraphics);
    has(Openable, [Openable.CLOSING]);
    has(Name, ['Command Door']);
    has(Description, ['A massive reinforced door']);

    reaction('collide', (thisEntity, thatEntity) {
      // FIXME: assumed everyone has access.
      thatEntity.emit('You crash into the command door!');
      thisEntity.emitNear('CLANK!');
      Openable o = thisEntity[Openable];
      if (o.isTransitioning) { return; }
      o.transition();
    });

    reaction('use', (thisEntity, thatEntity) {
      // FIXME: assumed everyone has access.
      Openable o = thisEntity[Openable];
      if (o.isTransitioning) { return; }

      thatEntity.emit('The door scans your ID and chirps happily');
      thisEntity.emitNear('Swoosh!');
      o.transition();
    });

    script('opened', (thisEntity) {
      thisEntity.components.remove(Collidable);
    });

    script('closed', (thisEntity) {
      thisEntity.attach(new Collidable());
    });
  }
}