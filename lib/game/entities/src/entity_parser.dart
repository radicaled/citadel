part of entities;

class EntityParser {
  Map<String, Type> knownComponents = {};

  EntityParser();

  Entity build(Map data) {
    var entity = new Entity(data['name']);
    data['components'].forEach((name, arguments) {
      var params = [arguments];
      params.removeWhere((p) => p == null);
      entity.attach(buildComponent(name, params));
    });

    return entity;
  }

  Component buildComponent(String name, [List parameters = const []]) {
    var type = knownComponents[name];
    if (type == null)
      throw "Type $name not known.";
    ClassMirror cm = reflectClass(type);
    return cm.newInstance(new Symbol(''), parameters).reflectee as Component;
  }

  register(String name, Type type) => knownComponents[name] = type;
}
