part of entities;

class CommandDoor extends EntityBuilder {
  _setup() {
    has(Position);
    has(Collidable);
    has(TileGraphics);
    has(Name, ['Command Door']);
    has(Description, ['A massive reinforced door']);

    reaction('collide', (thisEntity, thatEntity) {
      // FIXME: assumed everyone has access.
      thatEntity.emit('You crash into the command door!');
      thisEntity.emitNear('CLANK!');
      thisEntity.execute('opening');
    });

    reaction('use', (thisEntity, thatEntity) {
      // FIXME: assumed everyone has access.
      thatEntity.emit('The door scans your ID and chirps happily');
      thisEntity.emitNear('Swoosh!');
      thisEntity.execute('opening');
    });

    script('opening', (thisEntity) {
      // FIXME: could be triggered multiple times...
      // Should move to a state system.
      thisEntity.animate('opening');
    });

    script('opened', (thisEntity) {
      thisEntity.components.remove(Collidable);
    });
  }
}