part of entities;

class Floor extends EntityBuilder {
  _setup() {
    has(Position);
    has(TileGraphics);
  }
}
