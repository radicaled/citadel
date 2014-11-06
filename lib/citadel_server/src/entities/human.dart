part of citadel_server.entities;

class Human extends CEntityBuilder {
  setup() {
    has(Position);
    has(Velocity);
    has(Collidable);
    has(TileGraphics);
    has(Vision);
//    has(Inventory);
    has(Container);
    has(Health, [100]);
    has(Description, ['A generic human being']);
    has(Name, ['Steve']);

    behavior('use', (b) {
      b.after((ei) {
        var name = ei.target.has([Name]) ? ei.target[Name].text : 'something';
        world.emit('You recklessly fiddle with $name', fromEntity: ei.current, toEntity: ei.current);
      });

      b.activated((ei) => ei.target.react('use', ei.current, ei.invoker));
    });
  }
}
