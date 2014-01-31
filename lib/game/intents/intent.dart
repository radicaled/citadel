part of intents;

class Intent {
  String name;
  // The entity invoking this intent.
  // For most cases it will be a player's entity,
  // however in the case of an AI it might be something else entirely.
  int invokingEntityId;
  int targetEntityId;
  int withEntityId;
  // The action being performed via the entity specified by withEntityId.
  String actionName;

  Intent(this.name);
}