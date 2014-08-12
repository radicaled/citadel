part of game_ui;

class Label extends Sprite {
  String _text;
  String get text => _text;
         set text(String value) {
           _text = value;
           _drawText(text);
         }
  TextField tf = new TextField();

  int xPadding = 10;
  int yPadding = 10;

  Label([text]) {
    this.text = text;
    tf.textColor = Color.Black;
    addChild(tf);
  }

  _drawText(text) {
    tf.text = text;
    tf.x = 0 + xPadding;
    tf.y = 0 + yPadding;

    tf.width = tf.getLineMetrics(0).width + xPadding;
    tf.height = tf.getLineMetrics(0).height + yPadding;
  }
}