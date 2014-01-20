part of entities;

typedef BehaviorCallback(Entity thisEntity, Entity thatEntity);
class EntityBehavior {
  String name;
  Entity _thisEntity, _thatEntity;

  EntityBehavior(this.name, this._thisEntity, this._thatEntity);

  List<BehaviorCallback> _beforeCallbacks = [];
  List<BehaviorCallback> _afterCallbacks = [];

  bool isSatisfied = true;

  void perform() {
    if(!isSatisfied) { return; }

    _beforeCallbacks.forEach((bc) => bc(_thisEntity, _thatEntity));

    var reaction = _thatEntity.reactions[name];
    if (reaction != null) { reaction(_thatEntity, _thisEntity); }

    _afterCallbacks.forEach((bc) => bc(_thisEntity, _thatEntity));
  }

  // DSL
  require(Type componentType, [bool test(Component c)]) {
    if (isSatisfied == false) { return; }
    if (test == null) { test = (c) => true; };
    var component = _thisEntity[componentType];
    isSatisfied = component != null && test(component);
  }

  void before(BehaviorCallback bc) => _beforeCallbacks.add(bc);
  void after(BehaviorCallback bc) => _afterCallbacks.add(bc);
}