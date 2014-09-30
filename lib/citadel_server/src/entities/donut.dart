part of citadel_server.entities;

class Donut extends EntityBuilder {
  setup() {
    has(Position);
    has(Collidable);
    has(TileGraphics);
    has(Health, [100]);
    has(Damage, [30]);
    has(Description, ['A plain donut']);
    has(Name, ['Plain Donut']);
  }
}
