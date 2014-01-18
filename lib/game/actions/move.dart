part of actions;

class MoveAction extends Action {
  MoveAction(actioneer, target) : super(actioneer, target);

  requirements() {
    require(actioneer, Velocity);
  }

  perform() {
    var velocity = actioneer[Velocity];
    switch (options['direction']) {
      case 'N':
        velocity.y -= 1;
        break;
      case 'W':
        velocity.x -= 1;
        break;
      case 'S':
        velocity.y += 1;
        break;
      case 'E':
        velocity.x += 1;
        break;
    }
  }
}