library citaldel_server;

import 'package:game_loop/game_loop_isolate.dart';
import 'dart:io';

class CitadelServer {

  void start() {
    _startLoop();
    _startServer();
  }

  void _startLoop() {
    var gl = new GameLoopIsolate();

    gl.onUpdate = (gameLoop) {

    };

    gl.start();
  }

  void _startServer() {
    HttpServer.bind('127.0.0.1', 8000)
      .then((HttpServer server) {

        server.listen((HttpRequest request) {
           if (request.uri.path == '/ws') {
             WebSocketTransformer.upgrade(request).then((WebSocket websocket) {
               websocket.listen(_handleWebSocketMessage);
             });
           }
        });
    });
  }

  void _handleWebSocketMessage(message) {

  }
}