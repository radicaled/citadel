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
    _setupEvents();
  }

  _drawBackground([int color = Color.Black]) {
    graphics
      ..rect(0, 0, width, height)
      ..fillColor(color);
  }

  _drawText(text) {
    tf.text = text;
    tf.x = 0 + xPadding;
    tf.y = 0 + yPadding;

    tf.width = tf.getLineMetrics(0).width + xPadding;
    tf.height = tf.getLineMetrics(0).height + yPadding;
  }

  _setupEvents() {
    onMouseDown.listen((_) {
      _drawBackground(Color.Green);
    });

    onMouseUp.listen((_) {
      _drawBackground();
    });
  }
}