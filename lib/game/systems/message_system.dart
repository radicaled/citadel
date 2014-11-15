part of systems;

abstract class MessageSystem {
  Iterable<SystemMessage> filter(Iterable<SystemMessage> messages);
  void process(SystemMessage message);

  /// Filter a list of entities via [filter] and then apply the result to [process].
  void processMessages(Iterable<SystemMessage> messages) {
    filter(messages).forEach(process);
  }
}
