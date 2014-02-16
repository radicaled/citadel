part of components;

class Position extends Component {
  int x, y, z;
  Position([this.x = 0, this.y = 0, this.z = 0]);
  Position.from(Position other) : this(other.x, other.y, other.z);

  /**
   * Returns true if the [otherPosition] occupies the same X and Y coordinates, but not Z.
   */
  bool isSame2d(Position otherPosition) {
    return this.x == otherPosition.x && this.y == otherPosition.y;
  }

  operator >(Position other) => this.z > other.z;
  operator <(Position other) => this.z < other.z;
  operator ==(Position other) => this.x == other.x && this.y == other.y && this.z == other.z;
}