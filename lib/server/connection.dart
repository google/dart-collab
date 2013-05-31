part of server;

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
  static final StreamTransformer<dynamic, Message> _jsonToMessage =
      new StreamTransformer(handleData: (value, sink) {
        var message = new Message.parse(value);
        sink.add(message);
      });

  static final StreamTransformer<Message, String> _messageToJson =
      new StreamTransformer(handleData: (value, sink) {
        sink.add(value.json);
      });

  final WebSocket _socket;

  WebSocketConnection(WebSocket this._socket);

  Stream<Message> get stream => _jsonToMessage.bind(_socket);
  void add(Message message) => _socket.add(message.json);
  void addStream(Stream<Message> stream) =>
      _socket.addStream(_messageToJson.bind(stream));
  void close() => _socket.close();
}
