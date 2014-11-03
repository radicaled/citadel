part of citadel_server.entities;

class Hvac extends CEntityBuilder {
  setup() {
    has(Position);
    has(TileGraphics);
    has(Electronic);
    has(Name, ['An HVAC Unit']);
    has(Description, ['A Wall-Mounted HVAC unit']);

    reaction('use', (ei) {
      if (ei.current.has([Disabled])) {
        ei.current.emit(ei.current[Disabled].text);
        return;
      }
      // FIXME: this is hard-coded.
      var tilePhrases = ['Monitors|105', 'Monitors|137'];
      var tilePhrase = ei.current[TileGraphics].tilePhrases.first;
      tilePhrases.remove(tilePhrase);
      var newTilePhrase= tilePhrases.first;
      ei.current[TileGraphics].tilePhrases[0] = newTilePhrase;

      EntityManager.changed(ei.current);
    });

    reaction('disable', (ei) {
      // FIXME: This is hard-coded
      ei.current[TileGraphics].tilePhrases[0] = 'Monitors|133';
      ei.invoker.use((Name), (name) => world.emit('Alert! ${name.text} has tampered with... ffzzzztttttt!', nearEntity: ei.current));
      world.emit('The HVAC console makes a strange buzzing noise.', nearEntity: ei.current);

      ei.current.attach(new Disabled()..text= 'The console sparks at you.');
      EntityManager.changed(ei.current);
    });
  }
}
