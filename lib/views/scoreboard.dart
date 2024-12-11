import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/provider/room_data_provider.dart';

class ScoreBoard extends StatelessWidget {
  const ScoreBoard({super.key});

  @override
  Widget build(BuildContext context) {
    RoomDataProvider roomDataProvider = Provider.of<RoomDataProvider>(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Round counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
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
          const SizedBox(height: 16),
          // Players score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPlayerScore(
                nickname: roomDataProvider.player1.nickname,
                points: roomDataProvider.player1.points,
                playerType: 'X',
                isCurrentTurn: roomDataProvider.roomData['turn']?['socketID'] == 
                    roomDataProvider.player1.socketID,
              ),
              const Text(
                'vs',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 16,
                ),
              ),
              _buildPlayerScore(
                nickname: roomDataProvider.player2.nickname,
                points: roomDataProvider.player2.points,
                playerType: 'O',
                isCurrentTurn: roomDataProvider.roomData['turn']?['socketID'] == 
                    roomDataProvider.player2.socketID,
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
    required String playerType,
    required bool isCurrentTurn,
  }) {
    return Column(
      children: [
        Text(
          playerType,
          style: TextStyle(
            color: playerType == 'X' ? Colors.blue : Colors.red,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          nickname,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: isCurrentTurn ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          'Wins: $points',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}