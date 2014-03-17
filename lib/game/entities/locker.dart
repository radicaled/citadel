part of entities;

class Locker extends EntityBuilder {
  _setup() {
    has(Position);
    has(Collidable);
    has(TileGraphics);
    has(Openable, [Openable.CLOSING]);
    has(Container);
    has(Name, ['Locker']);
    has(Description, ['A locker full of goodies']);

    reaction('use', (thisEntity, thatEntity) {
      thatEntity.emitNear('The locker rustles');
      Openable o = thisEntity[Openable];
      if (!o.isTransitioning) { o.transition(); }
    });
  }
}