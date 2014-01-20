part of actions;

// This action exists for triggering behaviors on entities
class Interact extends Action {
  Interact(actioneer, target) : super(actioneer, target);
  requirements() {}

  perform() {
    var action_name = options['action_name'];
    var behavior = target.behaviors[action_name];
    if (behavior == null) {
      emit('You have tried to do the impossible.');
    } else {
      behavior(target, actioneer);
    }
  }
}