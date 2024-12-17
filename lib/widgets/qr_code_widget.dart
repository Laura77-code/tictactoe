import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeWidget extends StatelessWidget {
  final String roomId;

  const QRCodeWidget({
    Key? key,
    required this.roomId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('\n🎯 GENERATING QR CODE:');
    print('----------------------------------------');
    print('Room ID: $roomId');
    
    return QrImageView(
      data: roomId,
      version: QrVersions.auto,
      size: 200.0,
      backgroundColor: Colors.white,
    );
  }
} 