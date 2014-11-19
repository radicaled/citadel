part of citadel_server;

class AnimationSyncSystem extends EventSystem {
  ServerNetworkHub hub;

  AnimationSyncSystem(this.hub);

  Iterable<SystemMessage> filter(Iterable<SystemMessage> messages) =>
    messages.where((m) => m is LoginEvent);

  void process(SystemMessage message) {
    // TODO: could potentially send duplicate messages
    // EG, if a user logs in the moment an animation starts,
    // this system will also send an animate message.
    LoginEvent lm = message;

    AnimationCallbackSystem acs = world.getGenericSystem(AnimationCallbackSystem);

    acs.animationTimers.forEach((at) {
      // TODO: should we be deferring to another system to send messages?
      var elapsed = new DateTime.now().difference(at.startTime).inMilliseconds / 1000;
      hub
      ..animate(at.animatingEntity.id, at.animation.fullName,
        elapsed: elapsed)
      ..broadcast();
    });

  }
}
