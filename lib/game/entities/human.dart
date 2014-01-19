part of entities;

var _humanDef = entity('human', (eb) {
  eb.addAll([
              Position,
              Velocity,
              Collidable,
              TileGraphics,
              Vision,
              [Description, ['A generic human being']],
              [Name, ['The Toddster']]
             ]);

});