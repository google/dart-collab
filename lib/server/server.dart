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

library server;

import 'dart:io';
import 'dart:isolate';

import 'package:dart-collab/collab.dart';
import 'package:dart-collab/utils.dart';

part 'package:dart-collab/transport.dart';
part 'transport.dart';

typedef void RequestHandler(HttpRequest request, HttpResponse response);

class CollabServer {
  // clientId -> connection
  final Map<String, Connection> _connections;
  // docId -> document
  final Map<String, Document> _documents;
  // docId -> clientId
  final Map<String, Set<String>> _listeners;
  final Queue<Message> _queue;

  final Transport _transport;

  CollabServer(Transport this._transport)
    : _connections = new Map<String, Connection>(),
      _documents = new Map<String, Document>(),
      _listeners = new Map<String, Set<String>>(),
      _queue = new Queue<Message>() {

    _transport.onOpen = (Connection conn) {
      String clientId = randomId();
      _connections[clientId] = conn;
      print("new connection: $clientId");

      conn.onClosed = () {
        print("closed: $clientId");
        _removeConnection(clientId);
      };
      conn.onError = (e) {
        print("error: clientId: $clientId $e");
        _removeConnection(clientId);
      };
      conn.onMessage = (Message message) {
        _enqueue(message);
      };

      ClientIdMessage message = new ClientIdMessage(SERVER_ID, clientId);
      conn.send(message);
    };
  }

  void _enqueue(Message message) {
    _queue.add(message);
    _processDeferred();
  }

  void _processDeferred() {
    new Timer(0, (timer) => _process());
  }

  void _process() {
    if (!_queue.isEmpty) {
      _dispatch(_queue.removeFirst());
      _processDeferred();
    }
  }

  void _dispatch(Message message) {
    String clientId = message.senderId;
    print("dispatch: $message");
    switch (message.type) {
      case "create":
        create(clientId, message);
        break;
      case "log":
        print((message as LogMessage).text);
        break;
      case "open":
        OpenMessage m = message;
        _open(clientId, m.docId);
        break;
      case "close":
        CloseMessage m = message;
        _removeListener(clientId, m.docId);
        break;
      default:
        if (message is Operation) {
          _doOperation(message);
        } else {
          print("unknown message type: ${message.type}");
        }
    }
  }

  void _doOperation(Operation op) {
    Document doc = _documents[op.docId];
    // TODO: apply transform
    // transform by every applied op with a seq number greater than op.docVersion
    // those operations are in flight to the client that sent [op] and will
    // be transformed by op in the client. The result will be the same.
    Operation transformed = op;
    int currentVersion = doc.version;
    Queue<Operation> newerOps = new Queue<Operation>();
    for (int i = doc.log.length - 1; i >= 0; i--) {
      Operation appliedOp = doc.log[i];
      if (appliedOp.sequence > op.docVersion) {
        transformed = Operation.transform(transformed, appliedOp);
      }
    }
    doc.version++;
    transformed.sequence = doc.version;

    transformed.apply(doc);
    doc.log.add(transformed);
    _broadcast(transformed);
  }

  void _broadcast(Operation op) {
    Set<String> listenerIds = _listeners[op.docId];
    if (listenerIds == null) {
      print("no listeners");
      return;
    }
    for (String listenerId in listenerIds) {
//      if (listenerId != clientId) {
        _send(listenerId, op);
//      }
    }
  }

  void _send(String clientId, Message message) {
    Connection conn = _connections[clientId];
    if (conn == null) {
      // not sure why this happens sometimes
      _connections.remove(clientId);
      return;
    }
    conn.send(message);
  }

  void _open(String clientId, String docId) {
    if (_documents[docId] == null) {
      _create(docId);
    }
    _addListener(clientId, docId);
  }

  void _addListener(String clientId, String docId) {
    _listeners.putIfAbsent(docId, () => new Set<String>());
    _listeners[docId].add(clientId);
    Document d = _documents[docId];
    SnapshotMessage m = new SnapshotMessage(SERVER_ID, docId, d.text, d.version);
    _send(clientId, m);
  }

  void _removeListener(String clientId, String docId) {
    _listeners.putIfAbsent(docId, () => new Set<String>());
    _listeners[docId].remove(clientId);
  }

  void create(String clientId, CreateMessage message) {
    var d = _create(randomId());
    CreatedMessage m = new CreatedMessage(d.id, message.id);
    _send(clientId, m);
  }

  Document _create(String docId) {
    Document d = new Document(docId);
    _documents[d.id] = d;
    return d;
  }

  void _removeConnection(String clientId) {
    _connections.remove(clientId);
  }
}
