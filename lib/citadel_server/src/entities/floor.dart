part of citadel_server.entities;

class Floor extends CEntityBuilder {
  setup() {
    has(Position);
    has(TileGraphics);
  }
}
