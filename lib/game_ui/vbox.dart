part of game_ui;

class Vbox extends Sprite {
  int bWidth;
  int bHeight;
  int xPadding = 20;

  Vbox(this.bWidth, this.bHeight);

  void addChild(DisplayObject object) {
    var lastChild;
    var x = 0, y = 0;
    if (numChildren > 0) lastChild = getChildAt(numChildren - 1);
    if (lastChild != null) {
      x = (lastChild.x + lastChild.width) + xPadding;
      //y = (lastChild.y + lastChild.height);
    }
    object.x = x;
    object.y = y;
    super.addChild(object);
  }
}