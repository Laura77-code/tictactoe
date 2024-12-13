import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/provider/room_data_provider.dart';
import 'package:tictactoe/screens/main_menu_screen.dart';
import 'package:tictactoe/widgets/custom_button.dart';

class GameOverScreen extends StatelessWidget {
  final String result;
  const GameOverScreen({
    Key? key,
    required this.result,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RoomDataProvider roomDataProvider = Provider.of<RoomDataProvider>(context);
    
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              result,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Round ${roomDataProvider.currentRound}/${roomDataProvider.maxRounds}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'P1: ${roomDataProvider.player1.points} points',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            Text(
              'P2: ${roomDataProvider.player2.points} points',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 30),
            CustomButton(
              onTap: () {
                Navigator.pushNamed(context, MainMenuScreen.routeName);
              },
              text: 'Main Menu',
            ),
          ],
        ),
      ),
    );
  }
} 