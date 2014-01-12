part of entities;

var _wallDef = entity('wall', (eb) {
  eb.addAll([
             Position,
             Collidable,
             TileGraphics,
             [Description, ['A generic wall']]
             ]);
});