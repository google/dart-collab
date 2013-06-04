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

/*
 * A simple text-based document.
 */
class TextDocument extends Document {
  String _text;

  TextDocument(String id)
    : super(id),
      _text = "";

  String get content => _text;

  void set content(String content) {
    assert(content != null);
    modify(0, _text, content);
  }

  void modify(int position, String deleted, String inserted) {
    if ((position < 0) || (position > _text.length)) {
      throw "illegal position: $position, ${_text.length} text: $_text";
    }
    StringBuffer sb = new StringBuffer();
    sb.write(_text.substring(0, position));
    sb.write(inserted);
    sb.write(_text.substring(position + deleted.length));
    _text = sb.toString();
    DocumentChangeEvent event =
        new TextChangeEvent(this, position, deleted, inserted, _text);
    _fireUpdate(event);
  }

  String toString() => "Document {id: $id, text: $_text}";
}

/*
 * Describes a change to a body of text.
 */
class TextChangeEvent extends DocumentChangeEvent {
  final int position;
  final String deleted;
  final String inserted;
  final String text;

  TextChangeEvent(Document document, this.position, this.deleted,
      this.inserted, this.text)
    : super(document);

  String toString() =>
      "TextDocumentChangeEvent {$position, $deleted, $inserted}";
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
