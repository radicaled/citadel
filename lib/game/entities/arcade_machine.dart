part of entities;

class ArcadeMachine extends EntityBuilder {
  _setup() {
    has(Position);
    has(Collidable);
    has(TileGraphics);
    has(Health, [100]);
    has(Description, ['A blinking arcade machine']);
    has(Name, ['Arcade Machine']);
  }
}
