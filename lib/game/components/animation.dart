part of components;

class Animation extends Component {
  Queue<AnimationStep> steps;
  var onDone;
  Animation(List<AnimationStep> steps, {this.onDone}) {
    this.steps = new Queue.from(steps);
  }
}