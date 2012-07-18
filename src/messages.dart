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


/**
 * Tells a client what its id is after connecting.
 */
class ClientIdMessage extends Message {
  static String TYPE = "clientId";
  
  String clientId;
  
  ClientIdMessage(String senderId, this.clientId) : super(TYPE, senderId);
  
  ClientIdMessage.fromMap(Map<String, Object> map) 
    : super.fromMap(map),
    clientId = map['clientId'];

  toMap([values]) => super.toMap(mergeMaps(values, {'clientId': clientId}));
}

/**
 * Logs a simple message. Used for development and debugging.
 */
class LogMessage extends Message {
  static String TYPE = "log";
  
  final String text;
  
  LogMessage(String senderId, this.text) : super(TYPE, senderId);
  
  LogMessage.fromMap(Map<String, Object> map) 
    : super.fromMap(map),
      text = map['text'];
  
  toMap([values]) => super.toMap(mergeMaps(values, {'text': text}));
}
