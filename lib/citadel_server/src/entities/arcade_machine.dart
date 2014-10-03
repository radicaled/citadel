part of citadel_server.entities;

class ArcadeMachine extends CEntityBuilder {
  setup() {
    has(Position);
    has(Collidable);
    has(TileGraphics);
    has(Health, [100]);
    has(Description, ['A blinking arcade machine']);
    has(Name, ['Arcade Machine']);
  }
}
