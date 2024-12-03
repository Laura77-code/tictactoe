import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '/provider/room_data_provider.dart';
import '/resources/socket_client.dart';
import '/resources/game_methods.dart';
import '/screens/game_screen.dart';

class SocketMethods {
  final Socket? _socketClient = SocketClient.instance.socket;
  final GameMethods _gameMethods = GameMethods();

  Socket get socketClient => _socketClient!;

  void createRoom(String nickname) {
    if (nickname.isNotEmpty) {
      print('🎮 Creating room for: $nickname');
      print('🔌 Socket status: ${_socketClient?.connected}');
      print('🆔 Socket ID: ${_socketClient?.id}');
      
      _socketClient?.emit('createRoom', {
        'nickname': nickname,
      });
    }
  }

  void createRoomSuccessListener(BuildContext context) {
    _socketClient?.off('createRoomSuccess');
    
    _socketClient?.on('createRoomSuccess', (room) {
      print('✅ Room created successfully:');
      print('📋 Room data: $room');
      print('👥 Players count: ${room['players'].length}');
      
      if (!context.mounted) return;
      
      Provider.of<RoomDataProvider>(context, listen: false)
          .updateRoomData(Map<String, dynamic>.from(room));
      
      Navigator.pushNamed(context, GameScreen.routeName);
    });

    _socketClient?.off('startGame');
    _socketClient?.on('startGame', (room) {
      print('🎮 Starting game:');
      print('📋 Room data: $room');
      
      if (!context.mounted) return;
      
      Provider.of<RoomDataProvider>(context, listen: false)
          .updateRoomData(Map<String, dynamic>.from(room));
      
      Navigator.pushNamed(context, GameScreen.routeName);
    });
  }

  void pointIncreaseListener(BuildContext context) {
    _socketClient?.off('pointIncrease');

    _socketClient?.on('pointIncrease', (playerData) {
      print('🎯 Point increase for: ${playerData['nickname']}');

      if (!context.mounted) return;

      var roomDataProvider = Provider.of<RoomDataProvider>(context, listen: false);

      // Actualiza los puntos de los jugadores
      if (playerData['socketID'] == roomDataProvider.player1.socketID) {
        roomDataProvider.updatePlayer1(playerData);
      } else {
        roomDataProvider.updatePlayer2(playerData);
      }

      // Limpia el tablero después de actualizar puntos
      roomDataProvider.resetGame();

      print('Game reset after point increase.');
    });
  }

  void updateRoomListener(BuildContext context) {
    _socketClient?.off('updateRoom');

    _socketClient?.on('updateRoom', (room) {
      print('🔄 Room updated:');
      print('📋 Room data: $room');

      if (!context.mounted) return;

      final roomData = Map<String, dynamic>.from(room);

      // Actualiza los datos de la sala sin sobrescribir el estado reseteado
      Provider.of<RoomDataProvider>(context, listen: false).updateRoomData(roomData);
    });
  }


  void joinRoom(String nickname, String roomId) {
    if (nickname.isNotEmpty && roomId.isNotEmpty) {
      print('🎮 Joining room:');
      print('👤 Nickname: $nickname');
      print('🏠 Room ID: $roomId');
      
      _socketClient?.emit('joinRoom', {
        'nickname': nickname,
        'roomId': roomId,
      });
    }
  }

  void joinRoomSuccessListener(BuildContext context) {
    _socketClient?.off('joinRoomSuccess');
    
    _socketClient?.on('joinRoomSuccess', (room) {
      print('✅ Join room success:');
      print('📋 Room data: $room');
      
      if (!context.mounted) return;
      
      Provider.of<RoomDataProvider>(context, listen: false)
          .updateRoomData(Map<String, dynamic>.from(room));
      
      Navigator.pushNamed(context, GameScreen.routeName);
    });
  }

  void errorOccuredListener(BuildContext context) {
    _socketClient?.off('errorOccurred');
    
    _socketClient?.on('errorOccurred', (error) {
      print('❌ Error: $error');
      
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void tapGrid(int index, String roomId, List<String> displayElements) {
    if (displayElements[index] == '') {
      print('🎯 Tapping grid:');
      print('📍 Index: $index');
      print('🏠 Room ID: $roomId');
      print('📊 Current board state: $displayElements');
      
      _socketClient?.emit('tap', {
        'index': index,
        'roomId': roomId,
      });
    } else {
      print('❌ Invalid tap: Cell already occupied');
    }
  }

  void endGameListener(BuildContext context) {
    _socketClient?.off('endGame');

    _socketClient?.on('endGame', (gameData) {
      print('🏆 Game ended - Winner: ${gameData['winner']['nickname']}');

      if (!context.mounted) return;

      // Actualizar puntaje del ganador
      var roomDataProvider = Provider.of<RoomDataProvider>(context, listen: false);

      if (gameData['winner']['socketID'] == roomDataProvider.player1.socketID) {
        roomDataProvider.updatePlayer1(gameData['winner']);
      } else {
        roomDataProvider.updatePlayer2(gameData['winner']);
      }

      // Incrementar la ronda directamente
      roomDataProvider.incrementRound();

      // Notificar cambios inmediatamente
      roomDataProvider.notifyListeners();

      // Mostrar el diálogo del ganador
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          // Si ya hemos alcanzado el número máximo de rondas, mostrar opciones finales
          if (roomDataProvider.currentRound > roomDataProvider.maxRounds) {
            return AlertDialog(
              title: const Text('¡Juego terminado!'),
              content: const Text('El juego ha terminado. ¿Qué deseas hacer?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cierra el diálogo
                    roomDataProvider.resetAll(); // Reinicia el juego
                  },
                  child: const Text('Reiniciar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst); // Regresa al inicio
                  },
                  child: const Text('Volver al inicio'),
                ),
              ],
            );
          }

          // Mostrar el diálogo del ganador y limpiar el tablero después
          return AlertDialog(
            title: const Text('¡Tenemos un ganador!'),
            content: Text('¡${gameData['winner']['nickname']} ha ganado!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el diálogo
                  // Resetea el tablero después de cerrar el diálogo
                  roomDataProvider.resetGame();
                },
                child: const Text('Siguiente ronda'),
              ),
            ],
          );
        },
      );
    });
  }


  void tappedListener(BuildContext context) {
    _socketClient?.off('tapped');
    
    _socketClient?.on('tapped', (data) {
      print('🎯 Tap received:');
      print('📍 Index: ${data['index']}');
      print('🎮 Choice: ${data['choice']}');
      
      if (!context.mounted) return;
      
      var roomDataProvider = Provider.of<RoomDataProvider>(context, listen: false);
      
      roomDataProvider.updateDisplayElements(
        data['index'],
        data['choice'],
      );
      
      if (data['room'] != null) {
        roomDataProvider.updateRoomData(Map<String, dynamic>.from(data['room']));
      }

      print('📊 Current board state: ${roomDataProvider.displayElements}');
      print('📈 Filled boxes: ${roomDataProvider.filledBoxes}');
      print('🎲 Current turn: ${roomDataProvider.roomData['turn']['socketID']}');

      if (roomDataProvider.filledBoxes >= 5) {
        _gameMethods.checkWinner(context, _socketClient);
      }
    });
  }

  

  void dispose() {
    _socketClient?.off('createRoomSuccess');
    _socketClient?.off('joinRoomSuccess');
    _socketClient?.off('updateRoom');
    _socketClient?.off('startGame');
    _socketClient?.off('errorOccurred');
    _socketClient?.off('tapped');
    _socketClient?.off('pointIncrease');
    _socketClient?.off('endGame');
  }
}