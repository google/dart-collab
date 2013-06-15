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

library web_utils;

import 'dart:html';
import 'dart:math';
import 'package:collab/collab.dart' as collab;
import 'web_client.dart';

class TextChangeEvent {
  final Element target;
  final String text;
  final int position;
  final String deleted;
  final String inserted;

  TextChangeEvent(this.target, this.text, this.position, this.deleted,
      this.inserted);

  String toString() => "TextChangeEvent {text: $text, position: $position, "
      + "deleted: $deleted, inserted: $inserted}";
}

typedef void TextChangeHandler(TextChangeEvent e);

class TextChangeListener {
  final Element _element;
  final List<TextChangeHandler> _handlers;
  String _oldValue;

  TextChangeListener(this._element)
    : _handlers = new List<TextChangeHandler>() {
    _element.onKeyUp.listen((KeyboardEvent e) {
      int pos = (_element as dynamic).selectionStart;
      _onChange();
    });
    _element.onChange.listen((Event e) {
      int pos = (_element as dynamic).selectionStart;
      _onChange();
    });
    _oldValue = (_element as dynamic).value;
  }

  void addChangeHandler(TextChangeHandler handler) {
    _handlers.add(handler);
  }

  void reset() {
    _oldValue = (_element as dynamic).value;
  }

  /*
   * This algorithm works because there can only be one contiguous change as a
   * result of typing or pasting. If a paste contains a common substring with
   * the pasted over text, this will not attempt to find it and make more than
   * one delete/insert pair. This is actually good because it preserves user
   * intention when used in an OT system.
   */
  void _onChange() {
    String newValue = (_element as dynamic).value;

    if (newValue == _oldValue) {
      return;
    }

    int start = 0;
    int end = 0;
    int oldLength = _oldValue.length;
    int newLength = newValue.length;

    while ((start < oldLength) && (start < newLength)
        && (_oldValue[start] == newValue[start])) {
      start++;
    }
    while ((start + end < oldLength) && (start + end < newLength)
        && (_oldValue[oldLength - end - 1] == newValue[newLength - end - 1])) {
      end++;
    }

    String deleted = _oldValue.substring(start, oldLength - end);
    String inserted = newValue.substring(start, newLength - end);
    _oldValue = newValue;
    _fire(newValue, start, deleted, inserted);
  }

  void _fire(String text, int position, String deleted, String inserted) {
    TextChangeEvent event =
        new TextChangeEvent(_element, text, position, deleted, inserted);
    _handlers.forEach((handler) { handler(event); });
  }
}

void makeEditable(Element element, CollabWebClient client) {
  print("makeEditable");
  TextChangeListener listener = new TextChangeListener(element);

  bool listen = true;
  listener.addChangeHandler((TextChangeEvent event) {
    print(event);
    if (listen) {
      listen = false;
      collab.TextOperation op = new collab.TextOperation(client.id, "test",
          client.docVersion, event.position, event.deleted, event.inserted);
      client.queue(op);
      listen = true;
    }
  });

  client.document.addChangeHandler((collab.DocumentChangeEvent event) {
    if (listen && event is collab.TextChangeEvent) {
      listen = false;
      int cursorPos = (element as dynamic).selectionStart;
      (element as dynamic).value = event.text;
      if (event.position < cursorPos) {
        cursorPos =
            max(0, cursorPos + event.inserted.length - event.deleted.length);
      }
      (element as dynamic).setSelectionRange(cursorPos, cursorPos);
      listener.reset();
      listen = true;
    }
  });
}
