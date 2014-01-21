part of actions;

class PickupAction extends Action {
  PickupAction(actioneer, target) : super(actioneer, target);

  requirements() {}
  perform() {
    target.root = actioneer;
    var actionName = actioneer.has([Name]) ? actioneer[Name].text : 'Someone';
    var targetName = target.has([Name]) ? target[Name].text : 'Something';
    actioneer.emitNear('$actionName picks up the $targetName');
    EntityManager.hidden(target);
  }

}