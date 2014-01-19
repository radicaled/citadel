part of entities;

class Placeholder extends EntityBuilder {
  _setup() {
    has(Position);
    has(TileGraphics);
  }
}
