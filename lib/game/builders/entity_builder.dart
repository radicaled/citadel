part of builders;

class EntityBuilder {
  List<Type> components = [];
  
  void add(Type component) {
    components.add(component);
  }
  
  void addAll(List<Type> components) {
    this.components.addAll(components);
  }
}