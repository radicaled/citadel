part of game_ui;

class Button extends Sprite {
  String text;
  TextField tf;
  Button([this.text]) {
    if (text != null) {
      tf = new TextField();
      tf.text = text;
      tf.x = 0;
      tf.y = 0;

      //tf.width = 20;
      tf.height = 20;
      tf.textColor = Color.White;
      addChild(tf);
    }
    _drawBackground();
  }

  _drawBackground() {
    graphics
      ..rect(0, 0, width, height)
      ..fillColor(Color.Black);
  }
}