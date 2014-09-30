part of citadel_server.entities;

class Floor extends EntityBuilder {
  setup() {
    has(Position);
    has(TileGraphics);
  }
}
