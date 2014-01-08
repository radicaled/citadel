library builders;
import 'dart:mirrors';
import 'components.dart';

part 'builders/entity_builder.dart';
part 'builders/entity_definition.dart';

/* 
 * ... ... ...
 * Dart doesn't support top-level procedural code that's not a var assignment, so...
 * var foo = entity('foo', (eb) => /* whatever */);
 */
Map<String, EntityDefinition> get entityDefinitions => EntityDefinition._cache;
EntityDefinition entity(String name, EntityDefinitionFunction fxn) {
  return new EntityDefinition(name, fxn);
}