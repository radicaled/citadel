library behaviors;

import 'entities.dart';
import 'world.dart';

abstract class Behavior {
  List triggers = [];
  World world;
  Entity owner;

  setup(World world, Entity owner) {
    this.world = world;
    this.owner = owner;

    onTrigger(triggeringEntity) => update(triggeringEntity, owner);
    triggers.forEach((trigger) => owner.on(trigger, onTrigger));
  }

  update(Entity proxy, Entity target);
}