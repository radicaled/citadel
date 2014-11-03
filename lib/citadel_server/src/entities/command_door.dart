part of citadel_server.entities;

class CommandDoor extends CEntityBuilder {
  setup() {
    has(Position);
    has(Collidable);
    has(TileGraphics);
    has(Openable, [Openable.CLOSING]);
    has(Name, ['Command Door']);
    has(Description, ['A massive reinforced door']);

    reaction('collide', (ei) {
      // FIXME: assumed everyone has access.
      world.emit('You crash into the command door!', fromEntity: ei.current, toEntity: ei.target);
      world.emit('CLANK!!', nearEntity: ei.current, fromEntity: ei.current);
      Openable o = ei.current[Openable];
      if (o.isTransitioning) { return; }
      o.transition();
    });

    reaction('use', (ei) {
      // FIXME: assumed everyone has access.
      Openable o = ei.current[Openable];
      if (o.isTransitioning) { return; }
      // Need to detach emits from Entities.
      // Don't want entities to NEED access to the "World" class.
      // That kind of tight coupling got me into this mess
      // Component-based approach: add an "emittable" component to everything.
      // Seems awkward though. Plus, everything will want to emit SOMETHING at one point or another.
      // World.emit('Foo, bar');
      // Will become a God Class...
      // thatEntity[Emittable].emit(); // No null check?
      // vs (so long!!!)
      // But...
      // ei.target.with(Emittable, (emittable) => emittable.emit('The door scansy our ID and chirps happily'));
      world.emit('The door scans your ID and chirps happily', fromEntity: ei.current, toEntity: ei.target);
      world.emit('Swoosh!', nearEntity: ei.current, fromEntity: ei.current);
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
