part of entities;

typedef BehaviorCallback(EntityInteraction ei);

class EntityBehavior {
  String name;
  EntityInteraction ei;

  EntityBehavior(name, _thisEntity, _thatEntity, _invokingEntity) {
    ei = new EntityInteraction(_thisEntity, _thatEntity, _invokingEntity);
  }

  List<BehaviorCallback> _beforeCallbacks = [];
  List<BehaviorCallback> _afterCallbacks = [];
  List<BehaviorCallback> _activatedCallbacks = [];

  bool isSatisfied = true;

  void perform() {
    if(!isSatisfied) { return; }

    _beforeCallbacks.forEach((bc) => bc(ei));

    _activatedCallbacks.forEach((ac) => ac(ei));

    _afterCallbacks.forEach((bc) => bc(ei));
  }

  // DSL
  require(Type componentType, { bool test(Component c), onFail(EntityInteraction ei) }) {
    // TODO: clean up this entire method.
    if (isSatisfied == false) {
      if (onFail != null) { onFail(ei); }
      return;
    }
    if (test == null) { test = (c) => true; };
    var component = ei.current[componentType];
    isSatisfied = component != null && test(component);
    if (!isSatisfied) { onFail(ei); }
  }

  void before(BehaviorCallback bc) => _beforeCallbacks.add(bc);
  void after(BehaviorCallback bc) => _afterCallbacks.add(bc);
  void activated(BehaviorCallback bc) => _activatedCallbacks.add(bc);
}
