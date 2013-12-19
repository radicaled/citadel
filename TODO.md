* Multiplayer
    * Associate player with a connection
    * Add 'TILE' component to represent player visually.
    * On connection, send a series of PAINT commands to client for player positions (for now)
    * movementSystem queues up commands with entity ID that has changed position
* Track sockets, 'multiplayer'
* More entities?
* Refactor CitadelServer?
* Game loop with fixed time steps:

    http://nokarma.org/2011/02/02/javascript-game-development-the-game-loop/
    http://gamedev.stackexchange.com/questions/56956/how-to-make-a-game-tick-method