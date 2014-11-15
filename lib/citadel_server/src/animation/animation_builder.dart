part of citadel_server;

class AnimationBuilder {
  Entity entity;
  Animation entityAnimation;
  AnimationBuilder(this.entity) {
    if (entity[Animation] == null) { entity.attach(new Animation()); }
    entityAnimation = entity[Animation];
  }

  // Shorthand for new AnimationBuilder(entity);
  static AnimationBuilder on(Entity entity) {
    return new AnimationBuilder(entity);
  }

  // DSL

  /**
   * Add an animation step to the entity.
   * [graphicID] is a string representing the graphic to transition to.
   * [transition] is a time in milliseconds.
   */
  void animate(String graphicID, int transition, {onDone}) {
    entityAnimation.steps.add(new AnimationStep(graphicID, transition, onDone: onDone));
  }
}