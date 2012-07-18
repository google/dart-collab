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