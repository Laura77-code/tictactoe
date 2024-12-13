import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  IO.Socket? socket;
  static SocketClient? _instance;

  SocketClient._internal() {
    print('🔄 Initializing socket connection...');
    _connectSocket();
  }

  void _connectSocket() {
    try {
      print('\n🔄 INITIALIZING SOCKET CONNECTION:');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      print('\n🔄 Creating new socket connection...');
      socket = IO.io('http://localhost:3000', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
        'reconnection': true,
        'reconnectionAttempts': 5,
        'reconnectionDelay': 1000,
      });
      print('✅ Socket instance created');

      socket?.onConnect((_) {
        print('\n✅ SOCKET CONNECTED:');
        print('🔌 Socket ID: ${socket?.id}');
        print('📡 Transport: ${socket?.io.engine.transport?.name ?? "unknown"}');
      });

      socket?.onConnectError((err) {
        print('\n❌ CONNECTION ERROR:');
        print('Error: $err');
      });

      socket?.onDisconnect((_) {
        print('\n❌ SOCKET DISCONNECTED:');
        print('Previous Socket ID: ${socket?.id}');
      });

      socket?.onError((err) {
        print('\n❌ SOCKET ERROR:');
        print('Error: $err');
      });

      socket?.onReconnect((attempt) {
        print('\n🔄 SOCKET RECONNECTED:');
        print('Attempt Number: $attempt');
        print('New Socket ID: ${socket?.id}');
      });

      socket?.onReconnectAttempt((attempt) {
        print('\n🔄 RECONNECTION ATTEMPT $attempt:');
        print('Previous Socket ID: ${socket?.id}');
      });

      socket?.onReconnectError((error) {
        print('\n❌ RECONNECTION ERROR:');
        print('Error: $error');
        print('Connection State: ${socket?.connected}');
      });

      print('\n🔄 Attempting connection...');
      socket?.connect();
      print('✅ Connect method called');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    } catch (e, stackTrace) {
      print('\n❌ ERROR DURING SOCKET SETUP:');
      print('Error: $e');
      print('Stack Trace: $stackTrace');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
  }

  void reconnect() {
    print('🔄 Attempting to reconnect...');
    _connectSocket();
  }

  static SocketClient get instance {
    _instance ??= SocketClient._internal();
    return _instance!;
  }

  bool isConnected() {
    return socket?.connected ?? false;
  }
}