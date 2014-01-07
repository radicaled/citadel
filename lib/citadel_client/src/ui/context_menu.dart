part of citadel_client;

class ContextMenu {
  void show(container, String text) {
    var tf = new TextField(text);
    container.addChild(tf);
  }
}