library game_ui;

import 'package:stagexl/stagexl.dart';

part 'button.dart';
part 'vbox.dart';

typedef _dslFxn(GuiDSL);
typedef _containerFxn(ContainerDSL);
typedef BuilderFunction(builder);

class GameGui {
  static void construct(_dslFxn f) {
    f(new GuiDSL());
  }
}

class GuiDSL {
  Button button(String text) {
    return new Button(text);
  }

  Vbox vbox(int width, int height, BuilderFunction f) {
    var vbox = new Vbox(width, height);
    f(new ContainerDSL(vbox));
    return vbox;
  }
}

class ContainerDSL {
  DisplayObjectContainer container;
  ContainerDSL(this.container);

  set x(int value) => container.x = value;
  set y(int value) => container.y = value;

  void add(object) => container.addChild(object);
  void addAll(List objects) => objects.forEach((o) => container.addChild(o));
}
