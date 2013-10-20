part of tilemap;

class Tileset {
  num gid;
  num width;
  num height;
  String name;

  List<Image> images = new List<Image>();

  Tileset(this.gid);
}