part of citadel_client;

class LoginWindow {
  Element element;
  LoginWindow() {
    element = querySelector('.login-window').clone(true);
  }

  void show() {
    querySelector('#container').append(element);
  }

  void hide() {
    element.classes.add('hidden');
  }

  Stream get onLogin => element.querySelector('.login-window > form').onSubmit;
}
