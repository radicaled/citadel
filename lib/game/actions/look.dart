part of actions;

class LookAction extends Action {
  LookAction(actioneer, target) : super(actioneer, target);
  requirements() {
    require(actioneer, Vision);
    require(target, Description);
  }

  perform() {
    // TODO: should we trigger lookReaction AND emit the description?
    // Or should we just rely on lookReaction to emit the right text?
    target.react('look', actioneer, orElse: () => actioneer.emit(target[Description].text));
  }
}