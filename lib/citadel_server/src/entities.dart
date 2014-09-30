library citadel_server.entities;
import 'dart:mirrors';
import 'dart:async';

import 'components.dart';
import 'package:citadel/game/entities.dart';

part 'entities/wall.dart';
part 'entities/placeholder.dart';
part 'entities/floor.dart';
part 'entities/hvac.dart';
part 'entities/human.dart';
part 'entities/multi_tool.dart';
part 'entities/command_door.dart';
part 'entities/locker.dart';
part 'entities/arcade_machine.dart';
part 'entities/donut.dart';

var entityDefinitions = new Map<String, EntityBuilder>();
var _registered = false;

Entity buildEntity(String name) {
  if (!_registered) { _registerAll(); }
  var eb = entityDefinitions[name];
  if (eb == null) {
    throw new ArgumentError('Entity $name not found.');
  }

  return eb.build(name);
}

_registerAll() {
  _registerTypes();
  _registered = true;
}

_register(name, type) {
  entityDefinitions[name] = reflectClass(type).newInstance(new Symbol(''), []).reflectee;
}

_registerTypes() {
  _register('wall', Wall);
  _register('human', Human);
  _register('placeholder', Placeholder);
  _register('floor', Floor);
  _register('hvac', Hvac);
  _register('multi_tool', MultiTool);
  _register('command_door', CommandDoor);
  _register('locker', Locker);
  _register('gray_locker', Locker);
  _register('arcade_machine', ArcadeMachine);
  _register('plain_donut', Donut);
}



