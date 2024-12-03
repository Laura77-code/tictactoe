import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../resources/socket_client.dart';

class ConnectionStatusWidget extends StatefulWidget {
  const ConnectionStatusWidget({super.key});

  @override
  State<ConnectionStatusWidget> createState() => _ConnectionStatusWidgetState();
}

class _ConnectionStatusWidgetState extends State<ConnectionStatusWidget> {
  late bool isConnected;
  Socket? socket;

  @override
  void initState() {
    super.initState();
    socket = SocketClient.instance.socket;
    isConnected = socket?.connected ?? false;
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    socket?.on('connect', (_) {
      if (mounted) {
        setState(() {
          isConnected = true;
        });
        print('🔌 Socket connected');
      }
    });

    socket?.on('disconnect', (_) {
      if (mounted) {
        setState(() {
          isConnected = false;
        });
        print('🔌 Socket disconnected');
      }
    });

    socket?.on('connect_error', (error) {
      if (mounted) {
        setState(() {
          isConnected = false;
        });
        print('❌ Connection error: $error');
      }
    });
  }

  @override
  void dispose() {
    socket?.off('connect');
    socket?.off('disconnect');
    socket?.off('connect_error');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isConnected ? Icons.check_circle : Icons.error,
              key: ValueKey(isConnected),
              color: isConnected ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              isConnected ? 'Connected' : 'Disconnected',
              key: ValueKey(isConnected),
              style: TextStyle(
                color: isConnected ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}