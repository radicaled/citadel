Entity Interactions
===

A brief overview of how entities interact with each other in Citadel.

Behaviors
==

Behaviors describe actions that effect an entity as well as other entities.

Example:


A plasma welder has a 'weld' behavior. A number of things happen when this behavior is initiated:

1) We check if the weld behavior can be used.
	* Does the plasma welder have enough fuel?
2) We execute sub-behaviors that should run even if the primary behavior ('weld') fails for some reason.
	* Remove fuel
	* Apply damage or wear
3) At this stage, we signal the other entity that a behavior has been performed on it ('weld').
	* The target entity's reaction may or may not affect this entity.
4) Regardless of the target entity's `Reaction`, we execute sub-behaviors that should run afterwards.
	* Apply damage to target entity IF the plasma welder has been sabotaged.


Reactions
==

A Reaction is an entity-specific reaction to a behavior.

For instance, if a plasma welder is used on an HVAC console, it may permanently remove the HVAC console's cover, exposing its insides.

However, the entity also has a change to effect the interacting entity. For example, if the HVAC console as booby-trapped,
it might damage the plasma welder as well as the plasma welder's owner.

