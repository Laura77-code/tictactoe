import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/provider/room_data_provider.dart';
import '/screens/main_menu_screen.dart';
import '/utils/colors.dart';
import '/widgets/custom_button.dart';

class GameOverScreen extends StatelessWidget {
  static String routeName = '/game-over';
  final String result;
  const GameOverScreen({
    Key? key,
    required this.result,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final roomDataProvider = Provider.of<RoomDataProvider>(context);
    final player1 = roomDataProvider.player1;
    final player2 = roomDataProvider.player2;
    final winner = player1.points > player2.points ? player1 : player2;
    final isDraw = player1.points == player2.points;
    
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Trophy Animation
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Icon(
                      isDraw ? Icons.handshake : Icons.emoji_events_rounded,
                      size: 80,
                      color: Colors.white70,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              
              // Winner Text with Animation
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: value,
                    child: Text(
                      isDraw ? 'Draw' : '${winner.nickname} wins!',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              
              // Score Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  children: [
                    _buildPlayerCard(player1, isWinner: !isDraw && player1.points > player2.points),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'VS',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildPlayerCard(player2, isWinner: !isDraw && player2.points > player1.points),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              
              // Main Menu Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomButton(
                  onTap: () {
                    roomDataProvider.resetAll();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      MainMenuScreen.routeName,
                      (route) => false,
                    );
                  },
                  text: 'Main Menu',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerCard(Player player, {required bool isWinner}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isWinner ? Colors.blue.withOpacity(0.5) : Colors.white12,
            width: isWinner ? 2 : 1,
          ),
          boxShadow: isWinner ? [
            BoxShadow(
              color: Colors.blue.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ] : null,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                player.playerType,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: player.playerType == 'X' ? Colors.blue : Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              player.nickname,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              '${player.points} pts',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isWinner ? Colors.blue : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 