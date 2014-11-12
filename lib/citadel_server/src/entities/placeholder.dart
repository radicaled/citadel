part of citadel_server.entities;

class Placeholder extends CEntityBuilder {
  setup() {
    has(Position);
    has(TileGraphics);

    reaction('look', (ei) {
      var text = 'You are looking at Placeholder object ${ei.current.id} (graphic: ${ei.current[TileGraphics].currentGraphicID})';
      world.emit(text, toEntity: ei.invoker);
    });
  }
}
