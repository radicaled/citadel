part of actions;

class PickupAction extends Action {
  PickupAction(actioneer, target) : super(actioneer, target);

  requirements() {}
  perform() {
    actioneer.attach(new PickingUp(target, options['hand']));
  }

}