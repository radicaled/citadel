part of builders;

typedef void EntityDefinitionFunction(EntityBuilder eb);

class EntityDefinition {
  static Map<String, EntityDefinition> _cache = {};
  
  String name;
  EntityDefinitionFunction _definitionFunction;
  
  factory EntityDefinition(String name, EntityDefinitionFunction fxn) {
    var ed = new EntityDefinition._internal(name, fxn);
    _cache[name] = ed;
    return ed;
  }
  
  EntityDefinition._internal(this.name, this._definitionFunction);
  
  List<Component> build() {
    List<Component> components = [];
    var eb = new EntityBuilder();
    
    _definitionFunction(eb);
    
    eb.components.forEach((componentOrArray) {
      var component;
      var args = [];
      
      if (componentOrArray is List) {
        component = componentOrArray.first;
        args = componentOrArray.last;
      } else { component = componentOrArray; }
      
      var cm = reflectClass(component);
      Component newComponent = cm.newInstance(new Symbol(''), args).reflectee;
      components.add(newComponent);
    });
    
    return components;
  }
}