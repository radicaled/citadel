part of entities;

class Hvac extends EntityBuilder {
  _setup() {
    has(Position);
    has(TileGraphics);
    has(Name, ['An HVAC Unit']);
    has(Description, ['A Wall-Mounted HVAC unit']);
  }
}
