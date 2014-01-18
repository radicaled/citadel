Primary
==

* Fix content menu rendering?
* Start mapping more more entities

Secondary
==

* Interacting with the environment
    * What kind of UI?
        * SS13 is basically mouse-driven: right-click everything.
          * Need to send object names, but scope them by what's visible to the player (?).
            They'll know what's on the other side of the map if not.
               
* Scripting objects
    * Defining possible actions on an entity
        * Dart or YAML file?
* Systems
    * SS13 had a lot of complicated systems.
        * Can't use them directly, since the code is GPL3 -- I think it's code, anyway.
            Looked at one file, and frankly couldn't tell. Possibly a custom scripting language?
        * Start simple and extensible; when we're at this point we'll be ready to iterate it quickly.

* Refactor CitadelServer?
    * Lack of default namespaces are killing me here, Google. WTF, man.
* Synchronicity: should initialize gamestate before sending any other messages to new clients.
    * IOW, what happens when another client triggers a movement step, before the new client gets the gamestate?
    * Message queue for each websocket connection?
* Game loop with fixed time steps:

    http://nokarma.org/2011/02/02/javascript-game-development-the-game-loop/
    http://gamedev.stackexchange.com/questions/56956/how-to-make-a-game-tick-method
