part of entities;

class Hvac extends EntityBuilder {
  _setup() {
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
      var tiles = [2735, 2767];
      var gid = thisEntity[TileGraphics].tileGids.first;
      tiles.remove(gid);
      var newGid= tiles.first;
      thisEntity[TileGraphics].tileGids[0] = newGid;

      EntityManager.changed(thisEntity);
    });

    reaction('disable', (thisEntity, thatEntity) {
      // FIXME: This is hard-coded
      thisEntity[TileGraphics].tileGids[0] = 2763;
      thisEntity.emitNear('The HVAC console makes a strange buzzing noise.');
      thisEntity.attach(new Disabled()..text= 'The console sparks at you.');
      EntityManager.changed(thisEntity);
    });
  }
}
