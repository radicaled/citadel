part of game_ui;

class Vbox extends Container {
  int bWidth;
  int bHeight;
  int xPadding = 20;

  int _backgroundColor = Color.Transparent;
  int get backgroundColor => _backgroundColor;
  void set backgroundColor(int color) {
    _backgroundColor = color;
    _drawBackground(_backgroundColor);
  }

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

  _drawBackground([int color = Color.Transparent]) {
    graphics
      ..rect(0, 0, width, height)
      ..fillColor(color);
  }
}