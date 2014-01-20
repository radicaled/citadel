part of actions;

abstract class Action {
  Entity actioneer, target;
  Map options = {};
  bool isSatisfied = true;

  Action(this.actioneer, this.target);

  void requirements();
  void perform();

  void require(Entity entity, Type component) {
    if(isSatisfied == false) { return; }
    isSatisfied = entity.has([component]);
  }

  void execute() {
    requirements();
    if (isSatisfied) { perform(); }
  }
}