import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/provider/room_data_provider.dart';
import '/resources/socket_methods.dart';

class TicTacToeBoard extends StatefulWidget {
  const TicTacToeBoard({super.key});

  @override
  State<TicTacToeBoard> createState() => _TicTacToeBoardState();
}

class _TicTacToeBoardState extends State<TicTacToeBoard> {
  final SocketMethods _socketMethods = SocketMethods();

  @override
  void initState() {
    super.initState();
    _socketMethods.tappedListener(context);
  }

  void tapped(int index, RoomDataProvider roomDataProvider) {
    final currentSocketId = _socketMethods.socketClient.id;
    final currentTurn = roomDataProvider.roomData['turn']['socketID'];
    
    print('🎮 Tap attempt:');
    print('🔑 Current Socket ID: $currentSocketId');
    print('🎯 Current Turn ID: $currentTurn');
    print('📊 Board State: ${roomDataProvider.displayElements}');
    
    if (currentSocketId == currentTurn &&
        roomDataProvider.displayElements[index] == '') {
      _socketMethods.tapGrid(
        index,
        roomDataProvider.roomData['_id'],
        roomDataProvider.displayElements,
      );
      
      // Add debug print for move completion
      print('✅ Move completed at index: $index');
    } else {
      print('❌ Invalid move: ${currentSocketId != currentTurn ? "Not your turn" : "Space occupied"}');
    }
  }

  @override
  void dispose() {
    _socketMethods.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    RoomDataProvider roomDataProvider = Provider.of<RoomDataProvider>(context);
    final currentSocketId = _socketMethods.socketClient.id;
    final currentTurn = roomDataProvider.roomData['turn']['socketID'];

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
        maxWidth: 500,
      ),
      child: AbsorbPointer(
        absorbing: currentSocketId != currentTurn,
        child: GridView.builder(
          itemCount: 9,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () => tapped(index, roomDataProvider),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white24,
                  ),
                ),
                child: Center(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      roomDataProvider.displayElements[index] == 'X' ? '×' : 
                      roomDataProvider.displayElements[index] == 'O' ? '○' : '',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 72, // Reduced from 100
                        fontFamily: 'monospace',
                        shadows: [
                          Shadow(
                            blurRadius: 20, // Reduced from 40
                            color: roomDataProvider.displayElements[index] == 'O'
                                ? Colors.red.withOpacity(0.7)
                                : Colors.blue.withOpacity(0.7),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
