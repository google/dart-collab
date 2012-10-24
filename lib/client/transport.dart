part of web_client;

//  Copyright 2011 Google Inc. All Rights Reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.


/**
 * Message [Transport] implemented with dart:io WebSocket
 */
class WebSocketTransport implements Transport {
  final html.WebSocket _socket;
  _WebSocketConnection _conn;

  var onOpen;

  WebSocketTransport(String host)
    : _socket = new html.WebSocket(host) {
    _conn = new _WebSocketConnection(_socket);
    _socket.on.open.add((e) {
      if (onOpen != null) {
        onOpen(_conn);
      }
    });
    _socket.on.message.add((html.MessageEvent event) {
      String json = event.data;
      print(json);
      Message message = new Message.parse(json);
      _conn.onMessage(message);
    });
    _socket.on.error.add((e) => _conn.onError(e));
    _socket.on.close.add((e) => _conn.onClosed());
  }
}

class _WebSocketConnection implements Connection {
  final html.WebSocket _socket;
  var onMessage;
  var onClosed;
  var onError;

  _WebSocketConnection(this._socket);

  void send(Message message) {
    _socket.send(message.json);
  }

  void close() {
    _socket.close();
  }
}