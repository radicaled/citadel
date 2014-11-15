part of citadel_server.components;

class TileGraphics extends Component {
  /**
   * Tile phrases describe a tileset and a local tile ID.
   * EG, "Command Doors|0" references the Command Doors tileset,
   * with the target tile having a local ID of 0.
   */
  String get currentGraphicID => tilePhrases.first;
  List<String> tilePhrases = [];
  Queue<String> animationQueue = new Queue();
  TileGraphics([this.tilePhrases]);
}
