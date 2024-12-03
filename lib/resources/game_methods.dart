import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/provider/room_data_provider.dart';
import '/utils/utils.dart';
import 'package:socket_io_client/socket_io_client.dart';

class GameMethods {
  void checkWinner(BuildContext context, Socket socketClient) {
    RoomDataProvider roomDataProvider =
        Provider.of<RoomDataProvider>(context, listen: false);

    print('Checking winner - Filled boxes: ${roomDataProvider.filledBoxes}');
    print('Current board: ${roomDataProvider.displayElements}');

    // Minimum moves needed for a win is 5
    if (roomDataProvider.filledBoxes < 5) {
      print('Not enough moves to check winner yet');
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
        print('Winner found! Pattern: $combo, Symbol: $a');
        _handleWinner(context, socketClient, a, roomDataProvider);
        return;
      }
    }

    // Check for draw only if all boxes are filled and no winner
    if (roomDataProvider.filledBoxes == 9) {
      print('Game is a draw!');
      showGameDialog(context, '¡Empate!');
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
    print('Processing winner: $winner');
    
    // Determinar el jugador ganador
    final winnerPlayer = winner == 'X' ? roomDataProvider.player1 : roomDataProvider.player2;
    print('Winner nickname: ${winnerPlayer.nickname}');

    // Emitir evento de ganador
    socketClient.emit('winner', {
      'winnerSocketId': winnerPlayer.socketID,
      'roomId': roomDataProvider.roomData['_id'],
    });

    if (context.mounted) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('¡Tenemos un ganador!'),
            content: Text('¡${winnerPlayer.nickname} ha ganado!'), // Aquí agregamos el nombre
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  roomDataProvider.resetGame();
                },
                child: const Text('Siguiente ronda'),
              ),
            ],
          );
        },
      );
    }
  }
 
}