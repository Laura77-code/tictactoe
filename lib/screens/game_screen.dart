import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/provider/room_data_provider.dart';
import '/views/scoreboard.dart';
import '/views/tictactoe_board.dart';
import '/views/waiting_lobby.dart';
import '/resources/socket_methods.dart';

class GameScreen extends StatefulWidget {
  static String routeName = '/game';
  final bool isJoin;
  const GameScreen({
    Key? key,
    required this.isJoin,
  }) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final SocketMethods _socketMethods = SocketMethods();

  @override
  void initState() {
    super.initState();
    _socketMethods.updateRoomListener(context);
    _socketMethods.pointIncreaseListener(context);
    _socketMethods.endGameListener(context);
    _socketMethods.tappedListener(context);
    _socketMethods.gameRestartedListener(context);
  }

  static GameScreen create(BuildContext context, {bool? isJoin}) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return GameScreen(isJoin: isJoin ?? args?['isJoin'] ?? false);
  }

  @override
  void dispose() {
    super.dispose();
    _socketMethods.dispose();
  }

  @override
  Widget build(BuildContext context) {
    RoomDataProvider roomDataProvider = Provider.of<RoomDataProvider>(context);
    final size = MediaQuery.of(context).size;

    print('Building GameScreen:');
    print('Is Join: ${roomDataProvider.roomData['isJoin']}');
    print('Players: ${roomDataProvider.roomData['players']?.length}');

    return Scaffold(
      body: roomDataProvider.roomData['isJoin']
          ? const WaitingLobby()
          : SafeArea(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: size.width * 0.9,
                    maxHeight: size.height * 0.9,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Marcador
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: ScoreBoard(),
                      ),
                      const SizedBox(height: 40),
                      // Tablero de juego
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1, // Mantiene el tablero cuadrado
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return SizedBox(
                                  width: constraints.maxWidth,
                                  height: constraints.maxWidth,
                                  child: const TicTacToeBoard(),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Turno actual
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${roomDataProvider.roomData['turn']['nickname']}\'s turn',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}