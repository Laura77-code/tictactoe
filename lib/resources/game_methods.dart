import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/provider/room_data_provider.dart';
import '/utils/utils.dart';
import '/screens/game_over_screen.dart';
import 'package:socket_io_client/socket_io_client.dart';

class GameMethods {
  void checkWinner(BuildContext context, Socket socketClient) {
    RoomDataProvider roomDataProvider =
        Provider.of<RoomDataProvider>(context, listen: false);

    print('\n🔍 CHECKING WINNER:');
    print('📊 Filled boxes: ${roomDataProvider.filledBoxes}');
    print('🎲 Current Round: ${roomDataProvider.currentRound}');
    print('🎯 Max Rounds: ${roomDataProvider.maxRounds}');
    print('🎮 Current board: ${roomDataProvider.displayElements}');

    // Minimum moves needed for a win is 5
    if (roomDataProvider.filledBoxes < 5) {
      print('⏳ Not enough moves to check winner yet');
      return;
    }

    // Winning combinations
    final List<List<int>> winningCombos = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
      [0, 4, 8], [2, 4, 6]             // Diagonals
    ];

    for (final combo in winningCombos) {
      final a = roomDataProvider.displayElements[combo[0]];
      final b = roomDataProvider.displayElements[combo[1]];
      final c = roomDataProvider.displayElements[combo[2]];
      
      if (a != '' && a == b && b == c) {
        print('🏆 Winner found!');
        print('🎯 Winning Pattern: $combo');
        print('🎮 Winning Symbol: $a');
        _handleWinner(context, socketClient, a, roomDataProvider);
        return;
      }
    }

    // Check for draw only if all boxes are filled and no winner
    if (roomDataProvider.filledBoxes == 9) {
      print('🤝 Game is a draw!');
      showGameDialog(context, 'Draw!');
      Future.delayed(const Duration(milliseconds: 500), () {
        roomDataProvider.resetGame();
      });
    }
  }

  void _handleWinner(
    BuildContext context,
    Socket socketClient,
    String winner,
    RoomDataProvider roomDataProvider,
  ) {
    print('\n🎮 WINNER HANDLING:');
    print('🎲 Current Round: ${roomDataProvider.currentRound}');
    print('🎯 Max Rounds: ${roomDataProvider.maxRounds}');
    print('🏁 Winner Symbol: $winner');
    
    // Determine winner player
    final winnerPlayer = winner == 'X' ? roomDataProvider.player1 : roomDataProvider.player2;
    print('👑 Winner Player: ${winnerPlayer.nickname}');

    // Emit winner event
    socketClient.emit('winner', {
      'winnerSocketId': winnerPlayer.socketID,
      'roomId': roomDataProvider.roomData['_id'],
    });

    // Update room data with winner info immediately
    final updatedRoomData = Map<String, dynamic>.from(roomDataProvider.roomData);
    updatedRoomData['lastWinner'] = {
      'socketID': winnerPlayer.socketID,
      'round': roomDataProvider.currentRound
    };
    roomDataProvider.updateRoomData(updatedRoomData);

    // Reset game after delay
    Future.delayed(const Duration(seconds: 1), () {
      if (!context.mounted) return;

      print('📊 Updated Scores:');
      print('   ${roomDataProvider.player1.nickname}: ${roomDataProvider.player1.points}');
      print('   ${roomDataProvider.player2.nickname}: ${roomDataProvider.player2.points}');

      // Check if this is the last round
      bool isLastRound = roomDataProvider.currentRound >= roomDataProvider.maxRounds;
      print('🔍 Is this the last round? $isLastRound');

      if (isLastRound) {
        print('🏁 FINAL ROUND COMPLETED - Waiting for final scores');
        // Don't navigate here, let socket_methods.dart handle it when it gets final scores
      } else {
        print('🔄 Round ${roomDataProvider.currentRound} Complete');
        roomDataProvider.resetGame();
      }
    });
  }
 
}