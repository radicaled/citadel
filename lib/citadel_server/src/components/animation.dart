part of citadel_server.components;

class Animation extends Component {
  Queue<AnimationStep> steps = new Queue();
  Animation([List<AnimationStep> steps]) {
    if (steps != null) this.steps = new Queue.from(steps);
  }
}