import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  static io.Socket? _socket;
  static String _baseUrl = 'http://10.0.2.2:3000';

  static io.Socket? get socket => _socket;

  static void setBaseUrl(String url) {
    _baseUrl = url;
  }

  static void connect(String token) {
    try {
      if (_socket != null) {
        _socket!.disconnect();
        _socket!.dispose();
      }
      _socket = io.io(
        _baseUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': token})
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(10)
            .setReconnectionDelay(2000)
            .build(),
      );

      _socket!.onConnect((_) {
        print('Socket connected');
      });

      _socket!.onDisconnect((_) {
        print('Socket disconnected');
      });

      _socket!.onConnectError((err) {
        print('Socket connect error: $err');
      });
    } catch (e) {
      print('Socket error: $e');
    }
  }

  static void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  static void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  static void off(String event) {
    _socket?.off(event);
  }

  static void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }
}
