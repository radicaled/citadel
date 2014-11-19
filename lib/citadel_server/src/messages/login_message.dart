part of citadel_server;

class LoginMessage extends SystemMessage {
  GameConnection gc;

  LoginMessage(this.gc) : super('LOGIN_MESSAGE');
}
