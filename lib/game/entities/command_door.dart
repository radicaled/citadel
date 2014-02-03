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
      // FIXME: what happens if two people trigger this reaction at once?
      // We only want to run this new animation if an existing one is not running.
      AnimationBuilder.on(thisEntity)
        ..animate('Command Doors|2', 1)
        ..animate('Command Doors|3', 1)
        ..animate('Command Doors|4', 1)
        ..animate('Command Doors|5', 1)
        ..animate('Command Doors|6', 1)
        ..animate('Command Doors|7', 1, onDone: () => thisEntity.components.remove(Collidable));
    });
  }
}