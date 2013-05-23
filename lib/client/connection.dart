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

  StreamSubscription listen(void onData(data),
                            {void onError(error),
                             void onDone(),
                             bool cancelOnError}) {
    var transformer = new StreamTransformer(handleData: (value, sink) {
      if (value is html.MessageEvent) {
        var message = new Message.parse(value.data);
        sink.add(message);
      }
    });
    return _socket.onMessage.transform(transformer).listen(onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError);
  }

  void add(Message message) => _socket.send(message.json);

  Future close() => _socket.close();
}
