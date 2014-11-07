part of citadel_server;

class AnimationSystem extends EntitySystem {
  filter(Iterable<Entity> entities) =>
    entities.where((e) => e.has([Animation]));

  // TODO: client side rendering should alleviate some traffic, but then new clients have to be kept in sync with the animation...
  void process(Entity entity) {
    var ani = entity[Animation];
    AnimationStep currentStep = ani.steps.first;

    switch(currentStep.state) {
      case AnimationStep.NOT_STARTED:
        currentStep.start();
        entity[TileGraphics].tilePhrases = [currentStep.graphicID];
        EntityManager.changed(entity);
        break;
      case AnimationStep.FINISHED:
        if (currentStep.onDone != null) currentStep.onDone();
        ani.steps.removeFirst();
        break;
    }

    if (ani.steps.isEmpty) entity.components.remove(Animation);
  }
}
