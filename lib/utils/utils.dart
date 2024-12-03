import 'package:flutter/material.dart';
import '/provider/room_data_provider.dart';
import 'package:provider/provider.dart';

void showGameDialog(BuildContext context, String text) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Game Over'),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () {
              // Cambiado clearBoard por resetGame
              Provider.of<RoomDataProvider>(context, listen: false).resetGame();
              Navigator.pop(context);
            },
            child: const Text('Play Again'),
          ),
        ],
      );
    },
  );
}

void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}