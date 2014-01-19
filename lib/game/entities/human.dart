part of entities;

class Human extends EntityBuilder {
  _setup() {
    has(Position);
    has(Velocity);
    has(Collidable);
    has(TileGraphics);
    has(Vision);
    has(Description, ['A generic human being']);
    has(Name, ['Steve']);
  }
}
