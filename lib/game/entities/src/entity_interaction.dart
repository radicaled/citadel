part of entities;

/**
 * Describes an interaction between three entities:
 * [current]: the current entity performing the interaction
 * [invoker]: the invoker of this interaction
 * [target]: the target of the interaction
 */
class EntityInteraction {
  Entity current, invoker, target;
  EntityInteraction(this.current, this.target, this.invoker);
}
