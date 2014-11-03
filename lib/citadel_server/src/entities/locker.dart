part of citadel_server.entities;

class Locker extends CEntityBuilder {
  setup() {
    has(Position);
    has(Collidable);
    has(TileGraphics);
    has(Openable, [Openable.CLOSING]);
    has(Container);
    has(Name, ['Locker']);
    has(Description, ['A locker full of goodies']);

    reaction('use', (ei) {
      world.emit('The locker rustles', nearEntity: ei.current);
      Openable o = ei.current[Openable];
      if (!o.isTransitioning) { o.transition(); }
    });
  }
}
