part of tilemap;

class Tileset {
  int gid;
  int width;
  int height;
  String name;

  List<Image> images = new List<Image>();

  Tileset(this.gid);
}