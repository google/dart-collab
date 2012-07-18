
/**
 * Message [Transport] implemented with dart:io WebSocket
 */
class WebSocketTransport implements Transport {
  final html.WebSocket _socket;
  _WebSocketConnection _conn;
  
  var onOpen;
  
  WebSocketTransport(String host)
    : _socket = new html.WebSocket(host) {
    _conn = new _WebSocketConnection(_socket);
    _socket.on.open.add((e) {
      if (onOpen != null) {
        onOpen(_conn);
      }
    });
    _socket.on.message.add((html.MessageEvent event) {
      String json = event.data;
      print(json);
      Message message = new Message.parse(json);
      _conn.onMessage(message);
    });
    _socket.on.error.add((e) => _conn.onError(e));
    _socket.on.close.add((e) => _conn.onClosed());
  }
}

class _WebSocketConnection implements Connection {
  final html.WebSocket _socket;
  var onMessage;
  var onClosed;
  var onError;
  
  _WebSocketConnection(this._socket);
  
  void send(Message message) {
    _socket.send(message.json);
  }
  
  void close() {
    _socket.close();
  }
}