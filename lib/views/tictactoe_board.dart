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
    
    print('\n🎯 TAP ATTEMPT ON BOARD:');
    print('----------------------------------------');
    print('Index: $index');
    print('Current Socket: $currentSocketId');
    print('Turn Socket: $currentTurn');
    print('Cell Value: "${roomDataProvider.displayElements[index]}"');
    print('Board State: ${roomDataProvider.displayElements}');
    print('Is My Turn: ${currentSocketId == currentTurn}');
    print('Room Data: ${roomDataProvider.roomData}');
    
    if (currentSocketId == currentTurn &&
        roomDataProvider.displayElements[index] == '') {
      print('✅ Valid tap - sending to server');
      _socketMethods.tapGrid(
        index,
        roomDataProvider.roomData['_id'],
        roomDataProvider.displayElements,
      );
    } else {
      print('❌ Invalid tap:');
      print('Wrong turn: ${currentSocketId != currentTurn}');
      print('Cell occupied: ${roomDataProvider.displayElements[index] != ""}');
    }
    print('----------------------------------------');
  }

  Widget _buildSymbol(String symbol) {
    print('\n🎮 Building symbol: "$symbol"');
    if (symbol == '') {
      print('Empty cell - returning empty container');
      return const SizedBox();
    }

    print('Creating symbol widget for: $symbol');
    return Center(
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: 1.0,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: symbol == 'O' ? BoxShape.circle : BoxShape.rectangle,
            border: symbol == 'O' 
                ? Border.all(color: Colors.red.withOpacity(0.7), width: 3)
                : null,
          ),
          child: symbol == 'X'
              ? Transform.rotate(
                  angle: 45 * 3.14159 / 180,
                  child: Icon(
                    Icons.add,
                    size: 40,
                    color: Colors.blue.withOpacity(0.7),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    RoomDataProvider roomDataProvider = Provider.of<RoomDataProvider>(context);
    print('\n📱 BUILDING BOARD:');
    print('----------------------------------------');
    print('Display Elements: ${roomDataProvider.displayElements}');
    print('Current Turn: ${roomDataProvider.roomData['turn']?['nickname']}');
    print('Is My Turn: ${_socketMethods.socketClient.id == roomDataProvider.roomData['turn']?['socketID']}');
    print('----------------------------------------');

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
        maxWidth: 500,
      ),
      child: AbsorbPointer(
        absorbing: _socketMethods.socketClient.id != roomDataProvider.roomData['turn']['socketID'],
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
                    width: 0.5,
                  ),
                ),
                child: _buildSymbol(roomDataProvider.displayElements[index]),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _socketMethods.dispose();
    super.dispose();
  }
}
