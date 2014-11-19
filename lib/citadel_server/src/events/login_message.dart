part of citadel_server;

class LoginEvent extends SystemMessage {
  GameConnection gc;

  LoginEvent(this.gc) : super('LOGIN_MESSAGE');
}
