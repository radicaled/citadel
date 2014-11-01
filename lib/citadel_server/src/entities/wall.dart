part of citadel_server.entities;

class Wall extends CEntityBuilder {
  setup() {
    has(Position);
    has(Collidable);
    has(TileGraphics);
    has(Description, ['A generic wall']);
    has(Name, ['A wall']);
  }
}