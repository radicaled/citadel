part of entities;

class CommandDoor extends EntityBuilder {
  _setup() {
    has(Position);
    has(Collidable);
    has(TileGraphics);
    has(Name, ['Command Door']);
    has(Description, ['A massive reinforced door']);
  }
}