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

#library('demo_client');

#import('dart:html');
#import('../src/client/web_client.dart');
#import('../src/client/web_utils.dart');
#import('../src/collab.dart', prefix: 'collab');

TextAreaElement editor;
collab.Document doc;
Element statusDiv;

void main() {
  print("dart-collab demo");
  editor = query('#editor');
  statusDiv = query('#status');
  doc = new collab.Document("test");
  String host = window.location.hostname;
  print("host: $host");
  Transport transport = new WebSocketTransport("ws://$host:8080/connect");
  CollabWebClient client = new CollabWebClient(transport, doc);
  client.addStatusHandler(onStatusChange);
  makeEditable(editor, client);
}

void onStatusChange(int status) {
  switch (status) {
    case DISCONNECTED:
    case ERROR:
      statusDiv.classes.remove("connected");
      statusDiv.classes.remove("connecting");
      statusDiv.classes.add("disconnected");
      statusDiv.text = "disconnected";
      break;
    case CONNECTING:
      statusDiv.classes.remove("connected");
      statusDiv.classes.add("connecting");
      statusDiv.classes.remove("disconnected");
      statusDiv.text = "connecting";
      break;
    case CONNECTED:
      statusDiv.classes.add("connected");
      statusDiv.classes.remove("connecting");
      statusDiv.classes.remove("disconnected");
      statusDiv.text = "connected";
  }
}