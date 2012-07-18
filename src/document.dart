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

class DocumentChangeEvent {
  final Document document;
  final int position;
  final String deleted;
  final String inserted;
  final String text;
  
  DocumentChangeEvent(this.document, this.position, this.deleted, this.inserted, this.text);
  
  String toString() => "DocumentChangeEvent {$position, $deleted, $inserted}";
}

typedef void DocumentChangeHandler(DocumentChangeEvent e);

/*
 * A simple text-based document with a modification log.
 * 
 * TODO: rename to TextDocument
 */
class Document {
  final List<DocumentChangeHandler> _handlers;
  final String id;
  final List<Operation> log;
  String _text;
  int version;
  
  Document(this.id)
    : _handlers = new List<DocumentChangeHandler>(),
      log = new List(), _text = "", version = 0;
  
  void addChangeHandler(DocumentChangeHandler handler) {
    print("addChangeHandler");
    _handlers.add(handler);
  }
  
  void _fireUpdate(DocumentChangeEvent event) {
    print("fireUpdate");
    _handlers.forEach((handler) { handler(event); });
  }
  
  String get text() => _text;

  void modify(int position, String deleted, String inserted) {
    if ((position < 0) || (position > _text.length)) {
      throw "illegal position: $position, ${_text.length}";
    }
    StringBuffer sb = new StringBuffer();
    sb.add(_text.substring(0, position));
    sb.add(inserted);
    sb.add(_text.substring(position + deleted.length));
    _text = sb.toString();
    DocumentChangeEvent event = new DocumentChangeEvent(this, position, deleted, inserted, _text);
    _fireUpdate(event);
  }
  
//  void set text(String text) {
//    assert(text != null);
//    _text = text;
//    print("doc id:$id text: $_text");
//    _fireUpdate();
//  }
  
  String toString() => "Document {id: $id, text: $text}";  
}


/*
 * Creates a [Document]. This is not an operation because it does
 * not operate on an existing document.
 */
class CreateMessage extends Message {
  CreateMessage(String senderId) : super("create", senderId);
  CreateMessage.fromMap(Map<String, Object> map) : super.fromMap(map);
}

/*
 * Notifies a client that a document has been created.
 */
class CreatedMessage extends Message {
  String docId;
  CreatedMessage(this.docId, [String replyTo])
    : super("created", SERVER_ID, replyTo);
      
  CreatedMessage.fromMap(Map<String, Object> map) 
    : super.fromMap(map),
    docId = map['docId'];
  
  toMap([values]) => super.toMap(mergeMaps(values, {'docId': docId}));  
}

/*
 * Tells the server that a client wants to listen to a document.
 */
class OpenMessage extends Message {
  final String docId;
  
  OpenMessage(this.docId, String senderId) : super("open", senderId);
  
  OpenMessage.fromMap(Map<String, Object> map) 
    : super.fromMap(map),
      docId = map['docId'];
  
  toMap([values]) => super.toMap(mergeMaps(values, {'docId': docId}));
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
  final String text;
  final int version;
  
  SnapshotMessage(String senderId, this.docId, this.text, this.version) : super("snapshot", senderId);
  
  SnapshotMessage.fromMap(Map<String, Object> map) 
    : super.fromMap(map),
      docId = map['docId'],
      text = map['text'],
      version = map['version'];
  
  toMap([values]) => super.toMap(mergeMaps(values, 
      {'docId': docId, 'text': text, 'version': version}));
}
