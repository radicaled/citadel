import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'package:tmx/tmx.dart' as tmx;
import 'package:stagexl/stagexl.dart';
import 'package:js/js.dart' as js;
import 'package:citadel/citadel_client/citadel_client.dart' as c;

tmx.TileMapParser parser = new tmx.TileMapParser();
tmx.TileMap map;

Stage stage;
var resourceManager = new ResourceManager();
WebSocket ws;
int currentPlayerId;

Map<int, c.GameSprite> entities = new Map<int, c.GameSprite>();
c.ContextMenu currentContextMenu;
int currentActionIndex = 0;
int leftHand, rightHand;

void main() {
  var canvas = querySelector('#stage');
  canvas.focus();
  stage = new Stage(canvas);
  stage.focus = stage;

  canvas.onContextMenu.listen((event) => event.preventDefault() );

  stage.onMouseRightClick.listen((event) {
    if (currentContextMenu != null) { currentContextMenu.dismiss(); }
    var cmis = entities.values
        .where((gs) => gs.hitTestPoint(event.stageX, event.stageY))
        .map((gs) => new c.ContextMenuItem(gs.name, gs.entityId) )
        .toList();

    currentContextMenu = new c.ContextMenu(stage, cmis)
      ..show(event.stageX, event.stageY);
  });

  stage.onMouseClick.listen((event) {
    if (currentContextMenu != null) {
      var cm = currentContextMenu;
      if(!cm.displayable.hitTestPoint(event.stageX, event.stageY, true)) {
        cm.dismiss();
        currentContextMenu = null;
      }
    } else {
      // There was no context menu to interact with; they were trying to click on an entity.
      var gs = stage.hitTestInput(event.stageX, event.stageY);
      if (gs is c.GameSprite) {
        var ca = currentAction();
        var type = ca['type'];
        var actionName = ca['name'];
        var entityId = ca['entity_id'] != null ? int.parse(ca['entity_id']) : null;
        print('Tried to $actionName with ${gs.entityId} / ${gs.name} via $entityId');
        switch(type) {
          case 'action':
            intent(actionName.toUpperCase(), targetEntityId: gs.entityId);
            break;
          case 'interact':
            interactWith(gs.entityId, actionName, withEntityId: entityId);
            break;
        }
      }
    }

  });

  c.ContextMenu.onSelection.listen((cmi) {
    currentContextMenu.dismiss();
    currentContextMenu = null;
    print('Selected ${cmi.name} with value ${cmi.value}');
    // FIXME: right now, you can only look at items through right click selection.
    lookEntity(cmi.value);
  });
  // FIXME: this entire damn thing.
  canvas.onKeyPress.listen( (ke) {
    // a = 97
    // d = 100
    // s = 115
    // w = 119
    switch(ke.keyCode){
      case 97:
        movePlayer('MOVE_W');
        break;
      case 100:
        movePlayer('MOVE_E');
        break;
      case 115:
        movePlayer('MOVE_S');
        break;
      case 119:
        movePlayer('MOVE_N');
        break;
    }
    if (ke.keyCode >= 48 && ke.keyCode <= 57) {
      var number = ke.keyCode - 48;
      if (number == 0) { number = 10; } // Keyboard is 1234567890, not 0123456789
      selectAction(number - 1);
    }

  });

  var renderLoop = new RenderLoop();

  renderLoop.addStage(stage);

  var url = "//${window.location.host}/packages/citadel/assets/maps/shit_station-1.tmx";
  HttpRequest.getString(url)
    .then(loadMap)
    .then((_) => initWebSocket());
}

void selectAction(actionIndex) {
  var elements = querySelectorAll('ul#actions [data-type]');
  if (elements.length > actionIndex) {
    var element = elements.elementAt(actionIndex);
    currentActionIndex = actionIndex;
    querySelectorAll('ul#actions li.selected').forEach((e) => e.classes.remove('selected'));
    element.classes.add('selected');
  }
}

Map currentAction() {
  var element = querySelectorAll('ul#actions [data-type]').elementAt(currentActionIndex);
  return { 'name': element.attributes['data-action-name'],
    'type': element.attributes['data-type'],
    'hand': element.attributes['data-action-hand'],
    'entity_id': element.attributes['data-entity-id']
  };
}

void movePlayer(direction) {
  intent(direction);
}
// FIXME: this should be an interaction, right?
void pickupEntity(entityId, hand) {
  intent('PICKUP', targetEntityId: entityId);
}
// FIXME: this should be an interaction, right?
void lookEntity(entityId) {
  intent('LOOK', targetEntityId: entityId);
}

void interactWith(entityId, actionName, {withEntityId}) {
  intent('INTERACT', targetEntityId: entityId, withEntityId: withEntityId, actionName: actionName);
}

void intent(intentName, {targetEntityId, withEntityId, actionName}) {
  var payload = {
                  'intent_name': intentName,
                  'target_entity_id': targetEntityId,
                  'with_entity_id': withEntityId,
                  'action_name': actionName
                };
  send('intent', payload);

}

void send(type, payload) {
  ws.send(JSON.encode({ 'type': type, 'payload': payload }));
}

void initWebSocket([int retrySeconds = 2]) {
  var reconnectScheduled = false;
  print('Current Player ID: $currentPlayerId');
  ws = new WebSocket('ws://127.0.0.1:8000/ws/game');

  print("Connecting to websocket");


  void scheduleReconnect() {
    if (!reconnectScheduled) {
      new Timer(new Duration(milliseconds: 1000 * retrySeconds), () => initWebSocket(retrySeconds * 2));
    }
    reconnectScheduled = true;
  }

  ws.onOpen.listen((e) {
    print('Connected');
    querySelector('#ws-status').text = 'ONLINE';
  });

  ws.onClose.listen((e) {
    print('Websocket closed, retrying in $retrySeconds seconds');
    querySelector('#ws-status').text = 'OFFLINE';
    scheduleReconnect();
  });

  ws.onError.listen((e) {
    print("Error connecting to ws");
    scheduleReconnect();
  });

  ws.onMessage.listen((MessageEvent e) {
    print('Received message: ${e.data}');
    handleMessage(e.data);
  });

}

// TODO: I forgot what the Uint8 type is in JS. Uint8?
List<int> _inflateZlib(List<int> bytes) {
  var zlib = new js.Proxy(js.context.Zlib.Inflate, js.array(bytes));
  return zlib.decompress();
}

Future loadMap(String xml) {
  map = parser.parse(xml);

  map.tilesets.forEach( (tileset) {
    var image = tileset.images.first;

    // Welcome to 2013: where they still make languages without RegExp literals.
    var pattern = new RegExp(r"^\.\.");
    var imagePath = image.source.splitMapJoin(pattern, onMatch: (m) => "packages/citadel/assets");

    resourceManager.addBitmapData(tileset.name, imagePath);
  });

  return resourceManager.load();
}

void handleMessage(jsonString) {
  var msg = JSON.decode(jsonString);
  executeMessage(msg['type'], msg['payload']);
}

void executeMessage(type, payload) {
  switch (type) {
    case 'move_entity':
      _moveEntity(payload);
      break;
    case 'create_entity':
      _createEntity(payload);
      break;
    case 'update_entity':
      _updateEntity(payload);
      break;
    case 'remove_entity':
      _removeEntity(payload);
      break;
    case 'set_gamestate':
      payload.forEach((submessage) => executeMessage(submessage['type'], submessage['payload']));
      break;
    case 'emit':
      querySelector('#log').appendHtml('<p>${payload['text']}');
      break;
    case 'picked_up':
      _pickedUpEntity(payload);
  }
}

void _pickedUpEntity(payload) {
  var entityId = payload['entity_id'];
  var hand = payload['hand'];
  var selector = "#$hand-hand";
  querySelector(selector + ' h3').text = "$hand hand: ${payload['name']}";
  querySelectorAll(selector + ' [data-type]').forEach((e) => e.remove());
  var actionSelector = selector + ' ul.actions-for-hand';
  payload['actions'].forEach((action) {
    querySelector(actionSelector).appendHtml('<li data-type="interact" data-action-name="$action" data-action-hand="$hand" data-entity-id="$entityId">$action</li>');
  });
  ['attack', 'throw', 'drop'].forEach((action) {
    querySelector(actionSelector).appendHtml('<li data-type="action" data-action-name="$action" data-action-hand="$hand" data-entity-id="$entityId">$action</li>');
  });
}

// TODO: check to see if redundant entites have been created?
// EG, we already have an entity with ID=1, but now there are more?
void _createEntity(payload) {
  var s = new c.GameSprite();
  s.entityId = payload['entity_id'];
  s.name = payload['name'];
  s.x = payload['x'] * 32;
  s.y = payload['y'] * 32;

  (payload['tile_phrases'] as List).forEach((String tilePhrase) {
    var tile = map.getTileByPhrase(tilePhrase);
    var ss = getSpriteSheet(tile.tileset);
    s.addChild(new Bitmap(ss.frameAt(tile.tileId)));
  });

  stage.addChild(s);

  entities[s.entityId] = s;
}

void _updateEntity(Map payload) {
  var gs = entities[payload['entity_id']];
  if (payload.containsKey('x')) { gs.x = payload['x']; }
  if (payload.containsKey('y')) { gs.x = payload['x']; }

  if (payload.containsKey('tile_phrases')) {
    gs.removeChildren();
    (payload['tile_phrases'] as List).forEach((tilePhrase) {
      var tile = map.getTileByPhrase(tilePhrase);
      var ss = getSpriteSheet(tile.tileset);
      gs.addChild(new Bitmap(ss.frameAt(tile.tileId)));
    });
  }
}

void _removeEntity(payload) {
  var gs = entities.remove(payload['entity_id']);
  gs.removeFromParent();
}

void _moveEntity(payload) {
  var entity = entities[payload['entity_id']];
  entity.x = payload['x'] * 32;
  entity.y = payload['y'] * 32;
}

SpriteSheet getSpriteSheet(tmx.Tileset ts) {
  return new SpriteSheet(resourceManager.getBitmapData(ts.name), ts.width, ts.height);
}