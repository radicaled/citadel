part of behaviors;

@GameName("PlaceholderLookBehavior")
class PlaceholderLookBehavior extends Behavior {
  final triggers = ['look'];

  update(Entity proxy, Entity target) {
    var text = 'You are looking at Placeholder object ${target.id} (graphic: ${target[TileGraphics].currentGraphicID})';
    world.emit(text, toEntity: proxy);
  }
}