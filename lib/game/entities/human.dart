part of entities;

class Human extends EntityBuilder {
  _setup() {
    has(Position);
    has(Velocity);
    has(Collidable);
    has(TileGraphics);
    has(Vision);
    has(Health, [100]);
    has(Description, ['A generic human being']);
    has(Name, ['Steve']);

    behavior('use', (b) {
      b.after((thisEntity, thatEntity) {
        var name = thatEntity.has([Name]) ? thatEntity[Name].text : 'something';
        thisEntity.emit('You recklessly fiddle with $name');
      });
    });
  }
}
