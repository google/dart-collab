part of collab;

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


abstract class DocumentType {
  String get id;
  Document create(String id);
  Operation transform(Operation op, Operation by);
}

class DocumentChangeEvent {
  final Document document;

  DocumentChangeEvent(this.document);
}

typedef void DocumentChangeHandler(DocumentChangeEvent e);

abstract class Document {
  final String id;
  int version;
  final List<Operation> log;
  final List<DocumentChangeHandler> _handlers;

  Document(String this.id)
    : version = 0,
      log = new List<Operation>(),
      _handlers = new List<DocumentChangeHandler>() {
  }

  DocumentType get type;

  void addChangeHandler(DocumentChangeHandler handler) {
    assert(handler != null);
    print("addChangeHandler");
    _handlers.add(handler);
  }

  void fireUpdate(DocumentChangeEvent event) {
    print("fireUpdate");
    _handlers.forEach((handler) { handler(event); });
  }

  String serialize();
  void deserialize(String data);
}

/*
 * Creates a [Document]. This is not an operation because it does
 * not operate on an existing document.
 */
class CreateMessage extends Message {
  final String docType;

  CreateMessage(this.docType, String senderId) : super("create", senderId);

  CreateMessage.fromMap(Map<String, Object> map)
    : super.fromMap(map),
      docType = map['docType'];

  toMap([values]) => super.toMap(mergeMaps(values, {'docType': docType}));
}

/*
 * Notifies a client that a document has been created.
 */
class CreatedMessage extends Message {
  String docId;
  String docType;
  CreatedMessage(this.docId, this.docType, [String replyTo])
    : super("created", SERVER_ID, replyTo);

  CreatedMessage.fromMap(Map<String, Object> map)
    : super.fromMap(map),
    docId = map['docId'],
    docType = map['docType'];

  toMap([values]) =>
      super.toMap(mergeMaps(values, {'docId': docId, 'docType': docType}));
}

/*
 * Tells the server that a client wants to listen to a document.
 */
class OpenMessage extends Message {
  final String docId;
  final String docType;

  OpenMessage(this.docId, this.docType, String senderId)
    : super("open", senderId);

  OpenMessage.fromMap(Map<String, Object> map)
    : super.fromMap(map),
      docId = map['docId'],
      docType = map['docType'];

  toMap([values]) =>
      super.toMap(mergeMaps(values, {'docId': docId, 'docType': docType}));
}

/*
 * Tells the server that a client wants to stop listening to a document.
 */
class CloseMessage extends Message {
  final String docId;

  CloseMessage(String senderId, this.docId) : super("close", senderId);

  CloseMessage.fromMap(Map<String, Object> map)
    : super.fromMap(map),
      docId = map['docId'];

  toMap([values]) => super.toMap(mergeMaps(values, {'docId': docId}));
}

/*
 * Sends a snapshot of the current state of a document to a client.
 */
class SnapshotMessage extends Message {
  final String docId;
  final int version;
  final String content;

  SnapshotMessage(String senderId, this.docId, this.version, this.content)
    : super("snapshot", senderId);

  SnapshotMessage.fromMap(Map<String, Object> map)
    : super.fromMap(map),
      docId = map['docId'],
      version = map['version'],
      content = map['content'];

  toMap([values]) => super.toMap(mergeMaps(values,
      {'docId': docId, 'version': version, 'content': content}));
}
