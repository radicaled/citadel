part of citadel_server.entities;

class Placeholder extends EntityBuilder {
  setup() {
    has(Position);
    has(TileGraphics);
  }
}
