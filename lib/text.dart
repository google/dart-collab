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

class TextDocumentType extends DocumentType {
  static final TextDocumentType _INSTANCE = new TextDocumentType();

  String get id => "text";

  TextDocument create(String id) {
    return new TextDocument(id);
  }
}

/*
 * A simple text-based document.
 */
class TextDocument extends Document {
  String _content;

  TextDocument(String id)
    : this._content = "",
      super(id);

  TextDocument.fromString(String id, String this._content)
    : super(id);

  DocumentType get type => TextDocumentType._INSTANCE;

  void modify(int pos, String del, String ins) {
    if ((pos < 0) || (pos > _content.length)) {
      throw "illegal position: ${pos}, ${_content.length}";
    }
    StringBuffer sb = new StringBuffer();
    sb.write(_content.substring(0, pos));
    sb.write(ins);
    sb.write(_content.substring(pos + del.length));
    _content = sb.toString();
    var event = new TextChangeEvent(this, pos, del, ins, _content);
    fireUpdate(event);
  }

  String serialize() => _content;
  void deserialize(String content) => modify(0, _content, content);
}

/*
 * Describes a change to a body of text.
 */
class TextChangeEvent extends DocumentChangeEvent {
  final int position;
  final String deleted;
  final String inserted;
  final String text;

  TextChangeEvent(Document document, this.position, this.deleted, this.inserted,
      this.text)
    : super(document);

  String toString() =>
      "TextChangeEvent {$document.id, $position, $deleted, $inserted}";
}

/*
 * Inserts a string into a text document.
 */
class TextOperation extends Operation {
  final int position;
  final String deleted;
  final String inserted;

  TextOperation(String senderId, String docId, int docVersion, this.position,
      this.deleted, this.inserted)
    : super("text", senderId, docId, docVersion);

  TextOperation.fromMap(Map<String, Object> map)
    : super.fromMap(map),
      position = map['position'],
      deleted = map['deleted'],
      inserted = map['inserted'];

  toMap([values]) => super.toMap(mergeMaps(values, {
      'position': position, 'deleted': deleted, 'inserted': inserted}));

  void apply(TextDocument document) {
    document.modify(position, deleted, inserted);
  }

  static TextOperation transformInsert(TextOperation op, TextOperation by) {
    int newPosition = (by.position < op.position)
        ? op.position + (by.inserted.length - by.deleted.length)
        : op.position;
    // should docVersion be updated?
    // should [by] have to have a sequence number?
    // A: yes, and it should be less than op.docVersion
    return new TextOperation(op.senderId, op.docId, op.docVersion, newPosition,
        op.deleted, op.inserted);
  }
}
