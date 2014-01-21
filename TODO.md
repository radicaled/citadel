Primary
==

* Implement a 'HVAC' entity:
    * Turning it 'off' should change the tile graphic.
    * Turning it back 'on' should change the tile graphic to the 'on' graphic.
    * Using a multi-tool should 'disable' the 'HVAC', changing its tile permanently.


* Need to track items in hand / etc.
    * Update possible actions and UI too.
    
* Start mapping more more entities

Secondary
==

* Interacting with the environment
    * What kind of UI?
        * SS13 is basically mouse-driven: right-click everything.
          * Need to send object names, but scope them by what's visible to the player (?).
            They'll know what's on the other side of the map if not.

* Solving the conundrum of what the right thing to on left click:
  What if the active object had a set of activities associated with it?
    A naked fist would be, 'Grab', 'Help', 'Push', etc.
    A flame thrower might be 'Shoot', or even 'Weld.'
    A screwdriver might be 'Screw', 'Unscrew' or 'Stab'.

  The reality of SS13's current system is that Harm / Help / (?? Grab?) are pretty limited, and can
    easily be distilled into a core set of actions. Specifically, I think for the active hand,
    any possible actions are less than 5. Let's take a multitool as the most advanced example:
      * Detect power (is the device powered?)
      * Hack device (bypass security and bring up console)
      * Disable device (overload the device)

   Only three entity-specific actions. Let's throw in "throw" and "drop" since those things happen regularly.
     That's still only 5 actions. So, instead of the user fumbling and trying to discern what item does
     what in each situation, the outcome is pretty obvious based on actions. The fumbling is hilarious sometimes,
     particularly when it's not happening to you, but otherwise it makes the game pretty cumbersome to navigate.

   So, the easy way to handle UI is to simply select the appropriate action via number key and use left click to trigger
     that action. Some things have to have static #s associated with them -- drop and throw should always be the same no matter
     how many actions the item you're holding has, because you can throw (or drop) pretty much anything.
     It's also reasonable to just move those common keys to letters like 't' or 'd' or whatever floats my rickety boat.

   This also simplifes the backend considerably.
               
 Systems
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
