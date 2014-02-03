part of components;

class AnimationStep {
  static const NOT_STARTED = 'NOT_STARTED';
  static const RUNNING = 'RUNNING';
  static const FINISHED = 'FINISHED';

  String graphicID;
  // Transition time in milliseconds.
  int transition;

  Function onDone;

  DateTime _startedAt;

  String get state {
    if (_startedAt == null) return NOT_STARTED;
    return _startedAt.difference(new DateTime.now()).inMilliseconds.abs() >= transition ? FINISHED : RUNNING;
  }

  bool get isRunning => state == RUNNING;
  bool get isFinished => state == FINISHED;

  AnimationStep(this.graphicID, this.transition, {this.onDone});

  void start() {
    if (_startedAt == null) _startedAt = new DateTime.now();
  }

  void reset() {
    _startedAt = null;
  }
}