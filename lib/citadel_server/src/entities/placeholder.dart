part of citadel_server.entities;

class Placeholder extends CEntityBuilder {
  setup() {
    has(Position);
    has(TileGraphics);
  }
}
