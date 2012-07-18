
/**
 * Message [Transport] implemented with dart:io WebSocket
 */
class WebSocketTransport implements Transport {
  final WebSocketHandler _wsHandler;

  var onOpen;
  
  WebSocketTransport()
    : _wsHandler = new WebSocketHandler() {
    _wsHandler.onOpen = (WebSocketConnection wsConn) {
      _WebSocketConnection conn = new _WebSocketConnection(wsConn);
      if (onOpen != null) {
        onOpen(conn);
      }
    };
  }
  
  RequestHandler get handler() => _wsHandler.onRequest;
}

class _WebSocketConnection implements Connection {
  final WebSocketConnection _conn;

  var onMessage;
  var onClosed;
  var onError;
  
  _WebSocketConnection(this._conn) {
    _conn.onMessage = (json) {
      Message message = new Message.parse(json);
      onMessage(message);
    };
    _conn.onError = (e) => onError(e);
    _conn.onClosed = (s, r) => onClosed();
  }
  
  void send(Message message) {
    _conn.send(message.json);
  }
  
  void close() {
    _conn.close();
  }
  
}