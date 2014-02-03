part of components;

class Velocity extends Component {
  int x, y;
  Velocity([this.x = 0, this.y = 0]);

  void halt() {
    x = 0;
    y = 0;
  }
}