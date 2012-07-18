
interface Transport {
  void set onOpen(void callback(Connection connection));
}

interface Connection {
  void set onMessage(void callback(Message message));
  void set onClosed(void callback());
  void set onError(void callback(e));

  void send(Message message);
  void close();
}
