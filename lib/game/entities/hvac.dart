part of entities;

class Hvac extends EntityBuilder {
  _setup() {
    has(Position);
    has(TileGraphics);
    has(Name, ['An HVAC Unit']);
    has(Description, ['A Wall-Mounted HVAC unit']);

    can('toggle', (thisEntity, thatEntity) {
      // FIXME: this is hard-coded.
      var tiles = [2735, 2767];
      var gid = thisEntity[TileGraphics].tileGids.first;
      tiles.remove(gid);
      var newGid= tiles.first;
      thisEntity[TileGraphics].tileGids[0] = newGid;
    });
  }
}
