part of game_ui;

class Button extends Sprite {
  String text;
  TextField tf;

  int xPadding = 10;
  int yPadding = 10;

  Button([this.text]) {
    tf = new TextField();
    tf.textColor = Color.White;
    addChild(tf);

    _drawText(text);
    _drawBackground();
  }

  _drawBackground() {
    graphics
      ..rect(0, 0, width, height)
      ..fillColor(Color.Black);
  }

  _drawText(text) {
    tf.text = text;
    tf.x = 0 + xPadding;
    tf.y = 0 + yPadding;

    tf.width = tf.getLineMetrics(0).width + xPadding;
    tf.height = tf.getLineMetrics(0).height + yPadding;
  }
}