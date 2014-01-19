library entities;

import 'dart:mirrors';
import 'components.dart';
import 'builders.dart';

part 'entities/entity.dart';
part 'entities/wall.dart';
part 'entities/player.dart';
part 'entities/placeholder.dart';
part 'entities/floor.dart';
part 'entities/hvac.dart';
part 'entities/human.dart';
/* Dart's lazy initialization means that the right-hand members of a variable declaration
 * are not visited until the variable is accessed.
 *
 * Unfortunately, I've been unable to find a better work-around than this,
 * and it seems that the Dart devs on SO have confirmed that no better way exists.
 */

var _initialized = false;
var _entityDefPattern = new RegExp(r'^_(\w+)Def$');
void initialize() {
  var library = currentMirrorSystem().findLibrary(#entities);

  library.declarations.values
    .where((dec) => dec.isTopLevel && dec.isPrivate && dec is VariableMirror &&
      _entityDefPattern.hasMatch(MirrorSystem.getName(dec.simpleName)) )
    .forEach((dec) => library.getField(dec.simpleName).reflectee);

  _initialized = true;
}

Entity buildEntity(String name) {
  if(!_initialized) { initialize(); }

  if (!entityDefinitions.containsKey(name)) {
    throw new ArgumentError('Entity $name not found.');
  }

  var e = new Entity();
  var comps = entityDefinitions[name].build();

  comps.forEach((Component comp) => e.attach(comp));
  return e;
}
