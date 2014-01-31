Protocol message format
===

Websocket communications are sent in the form of:

{
    type: 'MESSAGE_TYPE',
    payload: ARRAY_OR_HASH
}


Client -> Server Protocl
===

get_gamestate
===

The client sends message when it is ready to receive the current gamestate.

The payload is an integer representing the current player / user.


look_at
==

    * payload.entity_id: entity id player wanted to look at

interact
==

FIXME: we need to track handiness, too. It's possible that we'll make hands entites of their own (as well as other body parts), in which case with_entity_id stops being optional as it should correspond to at the very least a hand or a tentacle or something.

The player is trying to interact with payload.entity_id.

    * payload.entity_id: entity id player is interacting with
    * payload.with_entity_id (OPTIONAL): id the entity the player is using to interact with the target entity.
      * if absent, it is assumed the player's active hand is in use.
    * payload.action_name: the action being taken

pickup
==

Pick up an object.

    * payload.entity_id: entity id player wanted to pick up

intent
==

The player intends to perform an action. A full list of intents is available in Intents.md

    * payload.intent_name: name of intent (eg, 'MOVE_W', 'PICKUP', etc)
    * payload.target_entity_id: (OPTIONAL) if the intent targets an entity, the id of that entity
    * payload.with_entity_id: (OPTIONAL) if the player is using an entity for this intent
    * payload.action_name: (OPTIONAL) contextual action possible (eg, 'SHOOT', 'DISABLE')

Server -> Client Protocol
===

set_gamestate
===

A batched set of commands that set the current gamestate.
The payload is an array of commands.

{
    type: set_gamestate,
    payload: [
        { type: 'set_entity', payload: { /* ... */ }
        /* ... */
    ]
}


create_entity
===

Create and render an entity on screen.

    * payload.entity_id: entity id for this entity.
    * payload.x: x location of this entity.
    * payload.y: y location of this entity.
    * payload.z: z location of this entity.
    * payload.tile_gids: an array of tile gids that visually represent this entity
    * payload.name: the name of this entity.


update_entity
===

Update an entity.

    * payload.entity_id: entity id to update
    * payload.tile_gids: (OPTIONAL) global tile id for updated entity.
        * if no tile_gids, then entity has not visually updated.
    * payload.x: (OPTIONAL) updated x location of this entity.
    * payload.y: (OPTIONAL) updated y location of this entity.
    * payload.z: (OPTIONAL) updated z location of this entity.

move_entity
===

Move an entity.

    * payload.entity_id: entity id to move.
    * payload.x: target x location for this entity.
    * payload.y: target y location for this entity.


remove_entity
===

Remove an entity from the game.

    * payload.entity_id: entity id to remove
    
    
emit
==

Some text that has been emitted

    * payload.text: text to be emitted

picked_up
==

The player is now holding an entity.

	* payload.entity_id: entity_id the player is holding
	* payload.name: name of the entity the player is holding
	* payload.hand: what hand the player is holding aforementioned entity
	* payload.actions: (array) a list of actions now available.
