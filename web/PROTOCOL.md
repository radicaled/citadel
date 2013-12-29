Protocl
===

Websocket communications are sent in the form of:

{
    type: 'MESSAGE_TYPE',
    payload: ARRAY_OR_HASH
}

Server Protocol
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