part of components;

class Position extends Component {
  int x, y, z;
  Position([this.x = 0, this.y = 0, this.z = 0]);
  Position.from(Position other) : this(other.x, other.y, other.z);
  operator ==(Position other) => this.x == other.x && this.y == other.y && this.z == other.z;
}