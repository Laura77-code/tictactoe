import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeWidget extends StatelessWidget {
  final String roomId;

  const QRCodeWidget({
    super.key,
    required this.roomId,
  });

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data: roomId,
      version: QrVersions.auto,
      size: 200.0,
      backgroundColor: Colors.white,
    );
  }
} 