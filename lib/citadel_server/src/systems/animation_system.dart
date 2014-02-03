part of citadel_server;

void animationSystem() {
  // TODO: client side rendering should alleviate some traffic, but then new clients have to be kept in sync with the animation...
  entitiesWithComponents([Animation]).forEach((entity) {
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
  });
}