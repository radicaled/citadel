part of entities;

class EntityParser {
  Map<String, Type> knownComponents = {};
  Map<String, Type> knownBehaviors = {};

  EntityParser();

  Entity build(Map data) {
    var entity = new Entity(data['name']);
    data['components'].forEach((name, arguments) {
      var params = [arguments];
      params.removeWhere((p) => p == null);
      entity.attachComponent(buildComponent(name, params));
    });

    var behaviors = data['behaviors'];
    if (behaviors != null) {
      behaviors.forEach((name) {
        entity.attachBehavior(buildBehavior(name));
      });
    }

    return entity;
  }

  Component buildComponent(String name, [List parameters = const []]) {
    var type = knownComponents[name];
    if (type == null)
      throw "Type $name not known.";
    ClassMirror cm = reflectClass(type);
    return cm.newInstance(new Symbol(''), parameters).reflectee as Component;
  }

  Behavior buildBehavior(String name) {
    var type = knownBehaviors[name];
    if (type == null)
      throw "Type $name not known";
    ClassMirror cm = reflectClass(type);
    return cm.newInstance(new Symbol(''), []).reflectee as Behavior;
  }

  registerComponent(String name, Type type) => knownComponents[name] = type;
  registerBehavior(String name, Type type) => knownBehaviors[name] = type;
}
