part of entities;

class Donut extends EntityBuilder {
  _setup() {
    has(Position);
    has(Collidable);
    has(TileGraphics);
    has(Health, [100]);
    has(Damage, [30]);
    has(Description, ['A plain donut']);
    has(Name, ['Plain Donut']);
  }
}
