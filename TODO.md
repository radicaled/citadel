* More entities?
* Refactor CitadelServer?
* Synchronicity: should initialize gamestate before sending any other messages to new clients.
    * IOW, what happens when another client triggers a movement step, before the new client gets the gamestate?
* Game loop with fixed time steps:

    http://nokarma.org/2011/02/02/javascript-game-development-the-game-loop/
    http://gamedev.stackexchange.com/questions/56956/how-to-make-a-game-tick-method