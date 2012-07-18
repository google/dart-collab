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
  final WebSocketHandler _wsHandler;

  var onOpen;
  
  WebSocketTransport()
    : _wsHandler = new WebSocketHandler() {
    _wsHandler.onOpen = (WebSocketConnection wsConn) {
      _WebSocketConnection conn = new _WebSocketConnection(wsConn);
      if (onOpen != null) {
        onOpen(conn);
      }
    };
  }
  
  RequestHandler get handler() => _wsHandler.onRequest;
}

class _WebSocketConnection implements Connection {
  final WebSocketConnection _conn;

  var onMessage;
  var onClosed;
  var onError;
  
  _WebSocketConnection(this._conn) {
    _conn.onMessage = (json) {
      Message message = new Message.parse(json);
      onMessage(message);
    };
    _conn.onError = (e) => onError(e);
    _conn.onClosed = (s, r) => onClosed();
  }
  
  void send(Message message) {
    _conn.send(message.json);
  }
  
  void close() {
    _conn.close();
  }
  
}