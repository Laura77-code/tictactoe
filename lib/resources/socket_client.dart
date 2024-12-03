import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  IO.Socket? socket;
  static SocketClient? _instance;

  SocketClient._internal() {
    print('🔄 Initializing socket connection...');
    _connectSocket();
  }

  void _connectSocket() {
    // Primero desconectamos si ya existe una conexión
    socket?.disconnect();
    socket?.dispose();

    // Creamos una nueva conexión
    socket = IO.io(
      'http://192.168.0.60:3000',  // Tu IP WiFi local
      {
        'transports': ['websocket', 'polling'],
        'autoConnect': false,
        'forceNew': true,
        'reconnection': true,
        'reconnectionAttempts': 5,
        'reconnectionDelay': 1000,
        'timeout': 5000,
      },
    );

    // Configuramos los listeners
    socket?.onConnect((_) {
      print('✅ Socket Connected');
      print('🔌 Socket ID: ${socket?.id}');
    });

    socket?.onConnecting((_) {
      print('🔄 Connecting to socket...');
    });

    socket?.onConnectError((data) {
      print('❌ Socket Connection Error: $data');
    });

    socket?.onDisconnect((_) {
      print('📴 Socket Disconnected');
    });

    socket?.onError((err) {
      print('❌ Socket Error: $err');
    });

    // Intentamos conectar
    try {
      socket?.connect();
    } catch (e) {
      print('❌ Error during connection: $e');
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