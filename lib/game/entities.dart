library entities;

import 'dart:mirrors';
import 'dart:async';
import 'components.dart';

// The only public API anyone needs to worry about here is 'buildEntity'
export 'entities.dart' show buildEntity;

part 'entities/src/entity_builder.dart';
part 'entities/src/entity_manager.dart';
part 'entities/src/entity_behavior.dart';

part 'entities/entity.dart';
part 'entities/wall.dart';
part 'entities/placeholder.dart';
part 'entities/floor.dart';
part 'entities/hvac.dart';
part 'entities/human.dart';
part 'entities/multi_tool.dart';



var entityDefinitions = new Map<String, EntityBuilder>();
var _registered = false;

Entity buildEntity(String name) {
  if (!_registered) { registerAll(); }
  var eb = entityDefinitions[name];
  if (eb == null) {
    throw new ArgumentError('Entity $name not found.');
  }

  return eb.build();
}

registerAll() {
  _registerTypes();
  _registered = true;
}

register(name, type) {
  entityDefinitions[name] = reflectClass(type).newInstance(new Symbol(''), []).reflectee;
}

_registerTypes() {
  register('wall', Wall);
  register('player', Player);
  register('human', Human);
  register('placeholder', Placeholder);
  register('floor', Floor);
  register('hvac', Hvac);
  register('multi_tool', MultiTool);
}

