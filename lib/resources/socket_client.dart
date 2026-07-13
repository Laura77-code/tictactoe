import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

const String SERVER_IP = '192.168.0.60';
const int SERVER_PORT = 3000;
const int CONNECTION_TIMEOUT = 10000; // 10 seconds
const int MAX_RECONNECTION_ATTEMPTS = 5;
const int INITIAL_RECONNECTION_DELAY = 1000;

class SocketClient {
  IO.Socket? socket;
  static SocketClient? _instance;
  Timer? _connectionTimer;
  int _reconnectionAttempts = 0;
  final _connectionStateController = StreamController<bool>.broadcast();

  // Getter for the connection state stream
  Stream<bool> get connectionState => _connectionStateController.stream;

  SocketClient._internal() {
    print('🔄 Initializing socket connection...');
    _connectSocket();
  }

  void _connectSocket() {
    try {
      print('\n🔄 INITIALIZING SOCKET CONNECTION:');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      // Cancel any existing connection timer
      _connectionTimer?.cancel();
      
      print('\n🔄 Creating new socket connection...');
      //final serverUrl = 'http://$SERVER_IP:$SERVER_PORT';
      final serverUrl = '';
      print('🔌 Connecting to: $serverUrl');
      
      socket = IO.io(serverUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
        'reconnection': true,
        'reconnectionAttempts': MAX_RECONNECTION_ATTEMPTS,
        'reconnectionDelay': INITIAL_RECONNECTION_DELAY,
        'reconnectionDelayMax': 5000,
        'randomizationFactor': 0.5,
      });

      // Set connection timeout
      _connectionTimer = Timer(Duration(milliseconds: CONNECTION_TIMEOUT), () {
        if (!(socket?.connected ?? false)) {
          print('\n⚠️ Connection timeout - attempting reconnect');
          _handleReconnection();
        }
      });

      socket?.onConnect((_) {
        print('\n✅ SOCKET CONNECTED:');
        print('🔌 Socket ID: ${socket?.id}');
        print('📡 Transport: ${socket?.io.engine.transport?.name ?? "unknown"}');
        _reconnectionAttempts = 0;
        _connectionStateController.add(true);
      });

      socket?.onConnectError((err) {
        print('\n❌ CONNECTION ERROR:');
        print('Error: $err');
      });

      socket?.onDisconnect((_) {
        print('\n❌ SOCKET DISCONNECTED:');
        print('Previous Socket ID: ${socket?.id}');
        _connectionStateController.add(false);
        _handleReconnection();
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
      _handleReconnection();
    }
  }

  void _handleReconnection() {
    if (_reconnectionAttempts >= MAX_RECONNECTION_ATTEMPTS) {
      print('\n❌ Max reconnection attempts reached');
      return;
    }

    _reconnectionAttempts++;
    final delay = INITIAL_RECONNECTION_DELAY * _reconnectionAttempts;
    
    print('\n🔄 Scheduling reconnection attempt $_reconnectionAttempts');
    print('⏰ Delay: ${delay}ms');
    
    Future.delayed(Duration(milliseconds: delay), () {
      if (!(socket?.connected ?? false)) {
        print('\n🔄 Attempting reconnection...');
        reconnect();
      }
    });
  }

  void reconnect() {
    socket?.dispose();
    socket = null;
    _connectSocket();
  }

  void dispose() {
    _connectionTimer?.cancel();
    _connectionStateController.close();
    socket?.dispose();
    socket = null;
    _instance = null;
  }

  static SocketClient get instance {
    _instance ??= SocketClient._internal();
    return _instance!;
  }

  bool isConnected() {
    return socket?.connected ?? false;
  }
}