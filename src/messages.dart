//#library('messages');
//
//#import('message.dart');
//#import('utils.dart');

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
