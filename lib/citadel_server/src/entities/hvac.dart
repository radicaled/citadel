part of citadel_server.entities;

class Hvac extends CEntityBuilder {
  setup() {
    has(Position);
    has(TileGraphics);
    has(Name, ['An HVAC Unit']);
    has(Description, ['A Wall-Mounted HVAC unit']);

    reaction('use', (thisEntity, thatEntity) {
      if (thisEntity.has([Disabled])) {
        thisEntity.emit(thisEntity[Disabled].text);
        return;
      }
      // FIXME: this is hard-coded.
      var tilePhrases = ['Monitors|105', 'Monitors|137'];
      var tilePhrase = thisEntity[TileGraphics].tilePhrases.first;
      tilePhrases.remove(tilePhrase);
      var newTilePhrase= tilePhrases.first;
      thisEntity[TileGraphics].tilePhrases[0] = newTilePhrase;

      EntityManager.changed(thisEntity);
    });

    reaction('disable', (thisEntity, thatEntity) {
      // FIXME: This is hard-coded
      thisEntity[TileGraphics].tilePhrases[0] = 'Monitors|133';
      world.emit('The HVAC console makes a strange buzzing noise.', nearEntity: thisEntity);
      thisEntity.attach(new Disabled()..text= 'The console sparks at you.');
      EntityManager.changed(thisEntity);
    });
  }
}
