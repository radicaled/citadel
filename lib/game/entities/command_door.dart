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

      // FIXME: should this be defined in JSON?
      var ani = new Animation([
                               new AnimationStep('Command Doors|2', 1),
                               new AnimationStep('Command Doors|3', 1),
                               new AnimationStep('Command Doors|4', 1),
                               new AnimationStep('Command Doors|5', 1),
                               new AnimationStep('Command Doors|6', 1),
                               new AnimationStep('Command Doors|7', 1)
                               ]);
      ani.onDone = () {
        thisEntity.components.remove(Collidable);
      };

      thisEntity.attach(ani);
    });
  }
}