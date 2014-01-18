part of actions;

abstract class Action {
  StreamController<String> _controller = new StreamController.broadcast();
  Stream onEmit;

  Map _requirements = {};
  Entity actioneer, target;
  bool isSatisfied;

  Action(this.actioneer, this.target) {
    onEmit = _controller.stream;
  }

  void requirements();
  void perform();

  void require(Entity entity, Type component) {
    if(isSatisfied == false) { return; }
    isSatisfied = entity.has([component]);
  }

  void execute({onEmit(String text)}) {
    if (onEmit != null) { this.onEmit.listen(onEmit); }

    requirements();
    if (isSatisfied) { perform(); }
    _controller.close();
  }

  // Emits some text to the actioneer
  void emit(String text) {
    _controller.add(text);
  }
}