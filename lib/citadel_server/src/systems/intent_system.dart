part of citadel_server;

typedef IntentSystemFunction(Intent intent);

class IntentSystem {
  List<Intent> intentQueue = new List();
  Map<String, List<IntentSystemFunction>> intentHandlers = new Map();

  register(String intentName, IntentSystemFunction system) {
    intentHandlers.putIfAbsent(intentName, () => []);
    intentHandlers[intentName].add(system);
  }

  execute() {
    intentQueue.forEach((intent) {
      var handlers = intentHandlers[intent.name];
      if (handlers == null) { return; }
      handlers.forEach((fxn) => fxn(intent));
    });
    intentQueue.clear();
  }
}

