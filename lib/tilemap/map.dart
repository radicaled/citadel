part of tilemap;

class Map {
  List<Tileset> tilesets = new List<Tileset>();
  List<Layer> layers = new List<Layer>();

  // Retrieve a tile based on its GID
  // GID is 1-based
  // From offical documentation:
  // In order to find out from which tileset the tile is you need to find the
  // tileset with the highest firstgid that is still lower or equal than the gid.
  // The tilesets are always stored with increasing firstgids.
  Tile getTileByGID(int gid) {
    var ts = tilesets.lastWhere((tileset) => tileset.gid <= gid, orElse: null);
    return new Tile(gid - (ts.gid - 1), ts);
  }
}