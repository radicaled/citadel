part of game_ui;

class Container extends Sprite {
  int _backgroundColor = Color.Black;
  int get backgroundColor => _backgroundColor;
  void set backgroundColor(int color) {
    _backgroundColor = color;
    update();
  }

  void update() {
    _drawBackground(_backgroundColor);
  }

  _drawBackground([int color = Color.Black]) {
    graphics
      ..rect(0, 0, width, height)
      ..fillColor(color);
  }
}