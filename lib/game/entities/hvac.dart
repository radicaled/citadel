part of entities;

var _hvacDef = entity('hvac', (eb) {
  eb.addAll([
             Position,
             TileGraphics,
             [Name, ['HVAC Control Unit']],
             [Description, ['An HVAC Control Unit']]
             ]);
});