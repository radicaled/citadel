part of citadel_server;

class TileGraphics extends Component {
  /*
    In the form of:
    {
      tile_gid: 1, /* Tile GID */
      z: 0 /* z-index of tile */
    }

   */
  List<int> tileGids;
  TileGraphics(this.tileGids);
}