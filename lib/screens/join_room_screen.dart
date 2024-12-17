import 'package:flutter/material.dart';
import '/resources/socket_methods.dart';
import '/responsive/responsive.dart';
import '/widgets/custom_button.dart';
import '/widgets/custom_textfield.dart';
import '/utils/colors.dart';
import '/screens/qr_scanner_screen.dart';

class JoinRoomScreen extends StatefulWidget {
  static String routeName = '/join-room';
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final TextEditingController _gameIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final SocketMethods _socketMethods = SocketMethods();
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    print('\n🎯 Setting up join room listeners');
    _socketMethods.joinRoomSuccessListener(context);
    _socketMethods.errorOccuredListener(context);
    _socketMethods.updateRoomListener(context);
  }

  void _scanQR() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your nickname first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final result = await Navigator.pushNamed(context, QRScannerScreen.routeName);
      if (result != null && mounted) {
        print('\n📱 QR SCAN RESULT:');
        print('----------------------------------------');
        print('Scanned code: $result');
        print('Nickname: ${_nameController.text}');
        
        setState(() {
          _gameIdController.text = result.toString();
          _isJoining = true;
        });
        
        print('✅ Game ID field updated');
        print('🔄 Attempting to join room...');
        
        if (mounted) {
          _socketMethods.joinRoom(
            _nameController.text,
            result.toString(),
          );
          print('✅ Join room request sent');
        } else {
          print('❌ Context not mounted, skipping join request');
        }
        print('----------------------------------------');
      }
    } catch (e) {
      print('❌ Error in QR scan:');
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error scanning QR code: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    print('🗑️ Disposing JoinRoomScreen');
    _gameIdController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: bgColor,
      body: Responsive(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Join Room',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 50,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: size.height * 0.08),
              Container(
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white24,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _nameController,
                      hintText: 'Enter your nickname',
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _gameIdController,
                      hintText: 'Enter Game ID',
                      suffix: IconButton(
                        icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                        onPressed: _scanQR,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.045),
              CustomButton(
                onTap: () => _socketMethods.joinRoom(
                  _nameController.text,
                  _gameIdController.text,
                ),
                text: 'Join',
              ),
            ],
          ),
        ),
      ),
    );
  }
}