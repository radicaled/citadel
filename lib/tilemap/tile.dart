part of tilemap;

class Tile {
  // Tile IDs are 1-based
  int tileId;
  Tileset tileSet;

  // Tile global IDs are 1-based
  int get gid => tileId + (tileSet.gid - 1);

  int width;
  int height;

  Tile(this.tileId, this.tileSet) {
    width = tileSet.width;
    height = tileSet.height;
  }
}