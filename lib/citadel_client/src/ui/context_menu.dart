part of citadel_client;

// Context Menu
// Currently only one can be displayed at a time.
class ContextMenu {
  static ContextMenu current;
  static StreamController<ContextMenuItem> _controller = new StreamController.broadcast();
  static Stream get onSelection => _controller.stream;

  DisplayObjectContainer _parent;
  Sprite displayable;
  List<ContextMenuItem> items;

  factory ContextMenu(DisplayObjectContainer parent, [List<ContextMenuItem> items]) {
    if (current != null) { current.dismiss(); }
    return current = new ContextMenu._internal(parent, items);
  }

  ContextMenu._internal(this._parent, this.items) {
    if (this.items == null) { items = new List(); }
    displayable = new Sprite();
  }

  void dismiss() {
    displayable.removeFromParent();
    current = null;
  }

  void show(num x, num y) {
    var width = 120;
    var height = 20 * items.length;

    displayable
      ..x = x
      ..y = y
      ..width = width
      ..height = height;

    var menuBkgrnd = new Shape()
      ..width = width
      ..height = height
      ..graphics.rect(0, 0, width, height)
      ..graphics.fillColor(Color.Aquamarine)
      ..graphics.strokeColor(Color.Red);

    displayable.addChild(menuBkgrnd);

    num itemX, itemY = 0;
    items.forEach((item) {
      var tf = new TextField(item.name)
        ..x = itemX
        ..y = itemY
        ..width = width
        ..height = 20;

      itemY += 20;

      tf.onMouseClick.listen((event) {
        _controller.add(item);
      });

      displayable.addChild(tf);
    });

    _parent.addChild(displayable);

  }
}