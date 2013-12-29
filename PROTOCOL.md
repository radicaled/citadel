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
    * payload.tile_gid: global tile id that visually represents this entity.
    * payload.x: x location of this entity.
    * payload.y: y location of this entity.


update_entity
===

Update an entity.

    * payload.entity_id: entity id to update
    * payload.tile_gid: (OPTIONAL) global tile id for updated entity.
        * if no tile_gid, then entity has not visually updated.
    * payload.x: updated x location of this entity.
    * payload.y: updated y location of this entity.

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