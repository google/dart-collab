part of web_client;

//  Copyright 2013 Google Inc. All Rights Reserved.
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

class WebSocketConnection implements Connection {
  final html.WebSocket _socket;

  WebSocketConnection(html.WebSocket this._socket);

  Stream<Message> get stream => _socket.onMessage
      .where((msg) => msg is html.MessageEvent)
      .map((msg) => msg.data);
  void add(String message) => _socket.send(message);
  void addStream(Stream<String> stream) {
    stream.listen((msg) => _socket.send(msg));
  }
  void close() => _socket.close();
}
