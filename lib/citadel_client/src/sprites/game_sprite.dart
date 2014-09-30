part of citadel_client;

class GameSprite extends Sprite {
  int entityId;
  String name;
  BitmapData bitmapData;
  bool selectable = true;
  // ???
  // Really need multi-parent display objects
  Sprite clone() {
    return new GameSprite()
      ..entityId = entityId
      ..name = name
      ..bitmapData = bitmapData
      ..addChild(new Bitmap(bitmapData));
  }
}