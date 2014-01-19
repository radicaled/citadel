part of entities;

class Wall extends EntityBuilder {
  _setup() {
    has(Position);
    has(Collidable);
    has(TileGraphics);
    has(Description, ['A generic wall']);
    has(Name, ['A wall']);
  }
}
