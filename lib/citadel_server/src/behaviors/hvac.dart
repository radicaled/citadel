part of behaviors;

@GameName("HvacUseBehavior")
class HvacUseBehavior extends Behavior {
  final triggers = ['use'];

  update(Entity proxy, Entity target) {
    if (target.has([Disabled])) {
      world.emit(target[Disabled].text, toEntity: target);
      return;
    }
    // FIXME: this is hard-coded.
    var tilePhrases = ['Monitors|105', 'Monitors|137'];
    var tilePhrase = target[TileGraphics].tilePhrases.first;
    tilePhrases.remove(tilePhrase);
    var newTilePhrase= tilePhrases.first;
    target[TileGraphics].tilePhrases[0] = newTilePhrase;

    EntityManager.changed(target);
  }
}

@GameName("HvacDisableBehavior")
class HvacDisableBehavior extends Behavior {
  final triggers = ['disable'];

  update(Entity proxy, Entity target) {
    // FIXME: This is hard-coded
    target[TileGraphics].tilePhrases[0] = 'Monitors|133';
    proxy.use((Name), (name) => world.emit('Alert! ${name.text} has tampered with... ffzzzztttttt!', nearEntity: target));
    world.emit('The HVAC console makes a strange buzzing noise.', nearEntity: target);

    target.attachComponent(new Disabled()..text= 'The console sparks at you.');
    EntityManager.changed(target);
  }
}