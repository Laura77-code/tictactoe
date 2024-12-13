import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/provider/room_data_provider.dart';

class ScoreBoard extends StatefulWidget {
  const ScoreBoard({super.key});

  @override
  State<ScoreBoard> createState() => _ScoreBoardState();
}

class _ScoreBoardState extends State<ScoreBoard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  String? lastWinnerSocketId;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkForWinner(RoomDataProvider provider) {
    final currentWinner = provider.roomData['lastWinner']?['socketID'];
    if (currentWinner != null && currentWinner != lastWinnerSocketId) {
      lastWinnerSocketId = currentWinner;
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    RoomDataProvider roomDataProvider = Provider.of<RoomDataProvider>(context);
    _checkForWinner(roomDataProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white12,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Round counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white12,
                width: 1,
              ),
            ),
            child: Text(
              'Round ${roomDataProvider.currentRound} of ${roomDataProvider.maxRounds}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Players score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPlayerScore(
                nickname: roomDataProvider.player1.nickname,
                points: roomDataProvider.player1.points,
                symbol: 'X',
                isCurrentTurn: roomDataProvider.roomData['turn']?['socketID'] == 
                    roomDataProvider.player1.socketID,
                isLastWinner: roomDataProvider.roomData['lastWinner']?['socketID'] == 
                    roomDataProvider.player1.socketID,
                scaleAnimation: _scaleAnimation,
              ),
              Container(
                height: 50,
                width: 1,
                color: Colors.white12,
              ),
              _buildPlayerScore(
                nickname: roomDataProvider.player2.nickname,
                points: roomDataProvider.player2.points,
                symbol: 'O',
                isCurrentTurn: roomDataProvider.roomData['turn']?['socketID'] == 
                    roomDataProvider.player2.socketID,
                isLastWinner: roomDataProvider.roomData['lastWinner']?['socketID'] == 
                    roomDataProvider.player2.socketID,
                scaleAnimation: _scaleAnimation,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerScore({
    required String nickname,
    required int points,
    required String symbol,
    required bool isCurrentTurn,
    required bool isLastWinner,
    required Animation<double> scaleAnimation,
  }) {
    return Column(
      children: [
        Text(
          nickname,
          style: TextStyle(
            color: isCurrentTurn ? Colors.white : Colors.white60,
            fontSize: 16,
            fontWeight: isCurrentTurn ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedBuilder(
          animation: scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: isLastWinner ? scaleAnimation.value : 1.0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isLastWinner 
                      ? Colors.white.withOpacity(0.15)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isLastWinner ? Colors.white24 : Colors.white12,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$points',
                      style: TextStyle(
                        color: isLastWinner ? Colors.white : Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isLastWinner)
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(
                          Icons.emoji_events_rounded,
                          color: Colors.amber,
                          size: 12,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}