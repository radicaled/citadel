part of entities;

class Locker extends EntityBuilder {
  _setup() {
    has(Position);
    has(Collidable);
    has(TileGraphics);
    has(Container, [Container.CLOSED]);
    has(Name, ['Locker']);
    has(Description, ['A locker full of goodies']);

    reaction('use', (thisEntity, thatEntity) {
      thatEntity.emitNear('The locker rustles');
      (thisEntity[Container] as Container).transition();
    });
  }
}