part of actions;

class LookAction extends Action {
  LookAction(actioneer, target) : super(actioneer, target);
  requirements() {
    require(actioneer, Vision);
    require(target, Description);
  }
  
  perform() {
    emit(target[Description].text);    
  }
}