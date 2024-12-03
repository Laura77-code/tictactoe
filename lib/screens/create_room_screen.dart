import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/provider/room_data_provider.dart';
import '/resources/socket_methods.dart';
import '/widgets/custom_button.dart';
import '/widgets/custom_text.dart';
import '/widgets/custom_textfield.dart';

class CreateRoomScreen extends StatefulWidget {
  static String routeName = '/create-room';
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController _nameController = TextEditingController();
  final SocketMethods _socketMethods = SocketMethods();

  @override
  void initState() {
    super.initState();
    _socketMethods.createRoomSuccessListener(context);
    _socketMethods.errorOccuredListener(context);
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RoomDataProvider>(
        builder: (context, roomDataProvider, child) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CustomText(
                  shadows: [
                    Shadow(
                      blurRadius: 40,
                      color: Colors.blue,
                    ),
                  ],
                  text: 'Create Room',
                  fontSize: 70,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                CustomTextField(
                  controller: _nameController,
                  hintText: 'Enter your nickname',
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.045),
                CustomButton(
                  onTap: () {
                    if (_nameController.text.isNotEmpty) {
                      _socketMethods.createRoom(_nameController.text);
                    }
                  },
                  text: 'Create',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}