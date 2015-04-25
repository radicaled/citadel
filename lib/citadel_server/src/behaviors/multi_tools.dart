part of behaviors;

@GameName("MultiToolUseBehavior")
class MultiToolUseBehavior extends Behavior {
  final triggers = ['use'];

  update(Entity proxy, Entity target) {
    bool hasRequiredPower = target.has([Power]) && target[Power].level > 15;
    if (!hasRequiredPower) {
      world.emit('The multi-tool makes a beep-boop noise, then falls silent.', nearEntity: target);
      return;
    }

    target[Power].level -= 15;

    world.emit('You hold the multi-tool up to the object and its interface lights up colorfully.', nearEntity: target);

    if (target.has([Electronic])) {
      target.receive('disable', proxy);
    }
  }
}