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
  final WebSocket _webSocket;

  WebSocketConnection(WebSocket this._webSocket);

  StreamSubscription listen(void onData(data),
                            {void onError(error),
                             void onDone(),
                             bool cancelOnError}) {
    var transformer = new StreamTransformer(handleData: (value, sink) {
      var message = new Message.parse(value);
      sink.add(message);
    });
    return _webSocket.transform(transformer).listen(onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError);
  }

  void add(Message message) => _webSocket.add(message.json);

  Future close() => _webSocket.close();
}