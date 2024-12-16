import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/provider/room_data_provider.dart';
import '/screens/create_room_screen.dart';
import '/screens/game_screen.dart';
import '/screens/join_room_screen.dart';
import '/screens/main_menu_screen.dart';
import '/screens/game_over_screen.dart';
import '/screens/qr_scanner_screen.dart';
import '/utils/colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RoomDataProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter TicTacToe',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: bgColor,
        ),
        initialRoute: MainMenuScreen.routeName,
        routes: {
          MainMenuScreen.routeName: (context) => const MainMenuScreen(),
          CreateRoomScreen.routeName: (context) => const CreateRoomScreen(),
          JoinRoomScreen.routeName: (context) => const JoinRoomScreen(),
          GameScreen.routeName: (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            return GameScreen(isJoin: args?['isJoin'] ?? false);
          },
          GameOverScreen.routeName: (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            return GameOverScreen(result: args?['result'] ?? 'Game Over');
          },
          QRScannerScreen.routeName: (context) => const QRScannerScreen(),
        },
      ),
    );
  }
}