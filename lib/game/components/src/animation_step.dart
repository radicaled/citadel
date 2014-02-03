part of components;

class AnimationStep {
  String tilePhrase;
  // Transition time in milliseconds.
  int transition;

  Stopwatch stopwatch = new Stopwatch();

  bool get isRunning => stopwatch.isRunning;
  bool get isFinished => stopwatch.elapsedMilliseconds > this.transition;

  AnimationStep(this.tilePhrase, this.transition);

  void start() {
    if (!stopwatch.isRunning) { stopwatch.start(); }
  }

  void finish() {
    stopwatch.stop();
  }
}