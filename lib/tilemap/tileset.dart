part of tilemap;

class Tileset {
  int gid;
  int width;
  int height;
  String name;

  Map map;

  List<Image> images = new List<Image>();

  Tileset(this.gid);
}