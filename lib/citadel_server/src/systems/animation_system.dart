part of citadel_server;

void animationSystem() {
  // TODO: client side rendering should alleviate some traffic, but then new clients have to be kept in sync with the animation...
  entitiesWithComponents([Animation]).forEach((entity) {
    var ani = entity[Animation];
    var currentStep = ani.steps.first;

    if (!currentStep.isRunning) {
      currentStep.start();
      entity[TileGraphics].tilePhrases = [currentStep.tilePhrase];
      EntityManager.changed(entity);
    } else if (currentStep.isFinished) {
      ani.steps.removeFirst();
    }

    if (ani.steps.isEmpty) {
      if (ani.onDone != null) { ani.onDone(); }
      entity.components.remove(Animation);
    }
  });
}