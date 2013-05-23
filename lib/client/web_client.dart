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

library web_client;

import 'dart:async';
import 'dart:html' as html;
import 'package:collab/collab.dart';

part 'connection.dart';

typedef void StatusHandler(int status);
const int DISCONNECTED = 0;
const int CONNECTED = 1;
const int CONNECTING = 2;
const int ERROR = 3;

class CollabWebClient {
  String _clientId;
  Document _document;
  Map<String, Completer> _pendingRequests; // might not be necessary anymore
  List<StatusHandler> _statusHandlers;

  // Operations that have not been sent to the server yet
  List<Operation> _queue;

  // The outstanding operation, if any.
  Operation _pending;

  // Operations received while the last sent operation is still pending.
  // These operations need to be transformed by the pending operation
  // if their sequence number is less than the pending operation.
  List<Operation> _incoming;

  final Connection _connection;

  CollabWebClient(Connection this._connection, Document this._document) {
    _pendingRequests = new Map<String, Completer>();
    _queue = new List<Operation>();
    _incoming = new List<Operation>();

    _statusHandlers = new List<StatusHandler>();
    _onStatusChange(CONNECTING);

    _connection.listen(
        (message) {
          _dispatch(message);
        },
        onError: (error) {
          _onStatusChange(ERROR);
          print("error: $error");
        },
        onDone: () {
          _onStatusChange(DISCONNECTED);
          print("closed");
        });
  }

  Document get document => _document;

  String get id => _clientId;

  int get docVersion => _document.version;

  // TODO: change away from send, since only the client can send
  // might need a separate envelope from message
  void queue(Operation operation) {
    operation.apply(_document);
    if (_pending == null) {
      _pending = operation;
      send(operation);
    } else {
      _queue.add(operation);
    }
  }

  void send(Message message) {
    _connection.add(message);
  }

  void addStatusHandler(StatusHandler h) {
    _statusHandlers.add(h);
  }

  void _onStatusChange(int status) {
    _statusHandlers.forEach((h) { h(status); });
  }

  void _dispatch(Message message) {
    if (message.type == "clientId") {
      _onClientId(message);
    } else if (message is Operation) {
      Operation op = message;
//      print("op: $op");
      if (op.senderId == _clientId) {
        // this should be the server transformed version of pending op
        // with it's sequence number set.
        // transform incoming ops by pending, since pending was transformed
        // by incoming on the server
        // don't apply op
        assert(op.id == _pending.id);
        List toRemove = [];
        _incoming.forEach((Operation i) {
          if (i.sequence < op.sequence) {
            var it = Operation.transform(i, _pending);
            _apply(it);
            toRemove.add(it);
          }
        });
        toRemove.forEach((i) {
          _incoming.removeRange(_incoming.indexOf(i), 1);
        });
        _pending.sequence = op.sequence;
        if (op.sequence > _document.version) {
          _document.version= op.sequence;
        } // else?
        _pending = null;
        if (!_queue.isEmpty) {
          _queue.forEach((o) { o.docVersion = op.sequence; });
          var next = _queue.removeAt(0);
          _pending = next;
          send(next);
        }
      } else {
        // transform by pending?
        // transform queued ops?
        if (_pending != null) {
          _incoming.add(op);
        } else {
          _apply(op);
        }
      }
    } else if (message is SnapshotMessage) {
      _onSnapshot(message);
    }
    if (message.replyTo != null) {
      _onReply(message);
    }
  }

  void _apply(Operation op) {
    op.apply(_document);
    _document.log.add(op);
    if (op.sequence > _document.version) {
      _document.version = op.sequence;
    }
  }

  /**
   * Handles a reply message, calling the correct callback.
   */
  void _onReply(Message response) {
    String replyTo = response.replyTo;
    if (replyTo != null) {
      Completer completer = _pendingRequests[replyTo];
      if (completer == null) {
        print("unknown message replied to: $replyTo");
        return;
      }
      _pendingRequests.remove(replyTo);
      completer.complete(response);
    }
  }

  void _onClientId(ClientIdMessage message) {
    _clientId = message.clientId;
    print("clientId: $_clientId");
    // once we have a clientId, open a test doc
    OpenMessage cm = new OpenMessage(_document.id, _clientId);
    send(cm);
    _onStatusChange(CONNECTED);
  }

  void _onSnapshot(SnapshotMessage message) {
    _document.modify(0, document.text, message.text);
    _document.version = message.version;
  }
}
