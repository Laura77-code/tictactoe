import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '/resources/socket_methods.dart';

class QRScannerScreen extends StatefulWidget {
  static String routeName = '/qr-scanner';
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  late MobileScannerController controller;
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
    print('📱 QR Scanner initialized');
  }

  void _handleQRDetected(String? roomId) {
    if (_hasScanned) {
      print('⚠️ QR already scanned, ignoring...');
      return;
    }
    
    print('\n🎯 QR CODE SCAN RESULT:');
    print('----------------------------------------');
    print('Room ID: ${roomId ?? 'Invalid'}');

    if (roomId != null && mounted) {
      setState(() => _hasScanned = true);
      print('✅ Valid room ID detected');
      
      // Cerrar la cámara
      print('📱 Stopping camera...');
      controller.stop();
      
      // Devolver el ID de la sala
      print('↩️ Returning to join room screen with ID');
      Navigator.pop(context, roomId);
    } else {
      print('❌ Invalid QR code data');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid QR code'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    print('----------------------------------------');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Room QR Code'),
      ),
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            _handleQRDetected(barcode.rawValue);
            return;
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    print('📱 Disposing QR Scanner');
    controller.dispose();
    super.dispose();
  }
} 