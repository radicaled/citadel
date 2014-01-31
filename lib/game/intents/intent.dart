part of intents;

class Intent {
  String name;
  // The entity invoking this intent.
  // For most cases it will be a player's entity,
  // however in the case of an AI it might be something else entirely.
  int invokingEntityId;
  int targetEntityId;
  int withEntityId;

  Intent(this.name);
}