import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '/provider/room_data_provider.dart';
import '/resources/socket_client.dart';
import '/resources/game_methods.dart';
import '/screens/game_screen.dart';
import '/screens/main_menu_screen.dart';
import '/screens/game_over_screen.dart';

class SocketMethods {
  final Socket _socketClient = SocketClient.instance.socket!;
  final GameMethods _gameMethods = GameMethods();

  Socket get socketClient => _socketClient;

  void createRoom(String nickname, int maxRounds) {
    if (nickname.isNotEmpty) {
      print('\n🎮 CREATING ROOM:');
      print('----------------------------------------');
      print('👤 Nickname: $nickname');
      print('🎯 Max Rounds: $maxRounds');
      print('🔌 Socket Connected: ${socketClient.connected}');
      print('🔑 Socket ID: ${socketClient.id}');
      
      try {
        socketClient.emit('createRoom', {
          'nickname': nickname,
          'maxRounds': maxRounds,
        });
        print('✅ Create room event emitted');
      } catch (e) {
        print('❌ Error emitting create room event:');
        print(e);
      }
      print('----------------------------------------');
    }
  }

  void createRoomSuccessListener(BuildContext context) {
    print('\n🎯 Setting up createRoomSuccess listener');
    try {
      socketClient.off('createRoomSuccess');
      print('✅ Previous createRoomSuccess listener removed');

      socketClient.on('createRoomSuccess', (room) {
        print('\n✨ CREATE ROOM SUCCESS EVENT RECEIVED:');
        print('----------------------------------------');
        print('🔑 Room ID: ${room['_id']}');
        print('👥 Players: ${room['players']?.length ?? 0}');
        print('🎯 Max Rounds: ${room['maxRounds']}');
        print('🎮 Is Join: ${room['isJoin']}');
        print('\n📊 Full Room Data:');
        room.forEach((key, value) {
          print('  ▸ $key: $value');
        });
        
        try {
          print('\n🔄 Updating Room Data Provider...');
          Provider.of<RoomDataProvider>(context, listen: false)
              .updateRoomData(room);
          print('✅ Room data updated successfully');
          
          print('\n🔄 Navigating to Game Screen...');
          Navigator.pushNamed(context, GameScreen.routeName);
          print('✅ Navigation successful');
        } catch (e, stackTrace) {
          print('\n❌ ERROR in create room success:');
          print('Error: $e');
          print('Stack Trace: $stackTrace');
        }
        print('----------------------------------------');
      });
      print('✅ New createRoomSuccess listener set up');
    } catch (e) {
      print('❌ Error setting up createRoomSuccess listener:');
      print(e);
    }
  }

  void pointIncreaseListener(BuildContext context) {
    _socketClient.off('pointIncrease');

    _socketClient.on('pointIncrease', (data) {
      if (!context.mounted) return;
      
      RoomDataProvider provider = Provider.of<RoomDataProvider>(context, listen: false);
      
      // Update state using handleWin
      provider.handleWin(data);
      provider.resetGame();
    });
  }

  void updateRoomListener(BuildContext context) {
    print('\n🎯 Setting up updateRoom listener');
    socketClient.off('updateRoom');
    
    socketClient.on('updateRoom', (room) {
      if (!context.mounted) {
        print('❌ Context not mounted in updateRoom');
        return;
      }

      try {
        Provider.of<RoomDataProvider>(context, listen: false).updateRoomData(room);
        print('✅ Room updated successfully');
      } catch (e) {
        print('❌ Error updating room: $e');
      }
    });
    print('✅ updateRoom listener setup complete');
  }


  void joinRoom(String nickname, String roomId) {
    if (nickname.isNotEmpty && roomId.isNotEmpty) {
      print('\n🎮 JOINING ROOM:');
      print('----------------------------------------');
      print('Nickname: $nickname');
      print('Room ID: $roomId');
      print('Socket Connected: ${socketClient.connected}');
      print('Socket ID: ${socketClient.id}');
      
      try {
        socketClient.emit('joinRoom', {
          'nickname': nickname,
          'roomId': roomId,
        });
        print('✅ Join room request emitted successfully');
      } catch (e) {
        print('❌ Error emitting join room event:');
        print(e);
      }
      print('----------------------------------------');
    }
  }

  void joinRoomSuccessListener(BuildContext context) {
    print('\n🎮 Setting up joinRoomSuccess listener');
    socketClient.off('joinRoomSuccess');
    
    socketClient.on('joinRoomSuccess', (room) async {
      print('\n🎮 JOIN ROOM SUCCESS EVENT RECEIVED:');
      print('----------------------------------------');
      print('Room ID: ${room['_id']}');
      print('Players: ${room['players']?.length ?? 0}');
      print('Is Join: ${room['isJoin']}');
      
      try {
        // 1. Actualizar el estado
        print('🔄 Updating room data...');
        if (!context.mounted) {
          print('❌ Context not mounted, aborting update');
          return;
        }
        Provider.of<RoomDataProvider>(context, listen: false).updateRoomData(room);
        print('✅ Room data updated');

        // 2. Navegar al juego
        print('🔄 Navigating to game screen...');
        if (!context.mounted) {
          print('❌ Context lost before navigation');
          return;
        }

        await Navigator.pushNamedAndRemoveUntil(
          context,
          GameScreen.routeName,
          (route) => false,
          arguments: {'isJoin': room['isJoin'] ?? false}
        );
        print('✅ Navigation completed');
        
      } catch (e, stack) {
        print('❌ Error in joinRoomSuccess:');
        print('Error: $e');
        print('Stack trace: $stack');
      }
      print('----------------------------------------');
    });
    print('✅ joinRoomSuccess listener setup complete');
  }

  void errorOccuredListener(BuildContext context) {
    print('\n🎯 Setting up error listener');
    try {
      _socketClient.off('errorOccurred');
      print('✅ Previous error listener removed');
      
      _socketClient.on('errorOccurred', (error) {
        print('\n❌ ERROR EVENT RECEIVED:');
        print('----------------------------------------');
        print('Error Message: $error');
        
        if (!context.mounted) {
          print('⚠️ Context not mounted, skipping error display');
          return;
        }
        
        try {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: Colors.red,
            ),
          );
          print('✅ Error snackbar displayed');
        } catch (e) {
          print('❌ Error showing snackbar: $e');
        }
        print('----------------------------------------');
      });
      print('✅ New error listener set up');
    } catch (e) {
      print('❌ Error setting up error listener: $e');
    }
  }

  void tapGrid(int index, String roomId, List<String> displayElements) {
    if (displayElements[index] == '') {
      print('\n🎯 SENDING TAP:');
      print('----------------------------------------');
      print('Index: $index');
      print('Room ID: $roomId');
      print('Board: $displayElements');
      
      _socketClient.emit('tap', {
        'index': index,
        'roomId': roomId,
      });
    }
  }

  void endGameListener(BuildContext context) {
    _socketClient.off('gameWin');
    _socketClient.off('gameEnd');
    _socketClient.off('draw');

    // Listener for draws
    _socketClient.on('draw', (data) {
      if (!context.mounted) return;
      
      print('\n🤝 DRAW EVENT RECEIVED:');
      print('----------------------------------------');
      print('Current Round: ${data['currentRound']}');
      
      var roomDataProvider = Provider.of<RoomDataProvider>(context, listen: false);
      
      print('\n📊 CURRENT STATE BEFORE DRAW UPDATE:');
      print('Round: ${roomDataProvider.currentRound}/${roomDataProvider.maxRounds}');
      print('P1: ${roomDataProvider.player1.nickname} - ${roomDataProvider.player1.points}pts');
      print('P2: ${roomDataProvider.player2.nickname} - ${roomDataProvider.player2.points}pts');
      
      // Update room data
      if (data['room'] != null) {
        roomDataProvider.updateRoomData(Map<String, dynamic>.from(data['room']));
      }
      
      // Check if this is the last round
      bool isLastRound = roomDataProvider.currentRound >= roomDataProvider.maxRounds;
      print('\n🔍 ROUND STATUS:');
      print('Current Round: ${roomDataProvider.currentRound}');
      print('Max Rounds: ${roomDataProvider.maxRounds}');
      print('Is Last Round: $isLastRound');
      
      if (isLastRound) {
        print('\n🏁 FINAL ROUND DRAWN:');
        print('Waiting for game end event...');
      } else {
        print('\n🔄 Round Complete - Resetting game board');
        roomDataProvider.resetGame();
        
        // Emit restart event to ensure all clients are in sync
        _socketClient.emit('restart_game', {
          'roomId': roomDataProvider.roomData['_id'],
        });
      }
    });

    // Listener for normal wins
    _socketClient.on('gameWin', (data) {
      if (!context.mounted) return;
      
      print('\n🎮 GAME WIN EVENT RECEIVED:');
      print('----------------------------------------');
      print('Winner Socket ID: ${data['winnerSocketId']}');
      
      var roomDataProvider = Provider.of<RoomDataProvider>(context, listen: false);
      
      print('\n📊 CURRENT STATE BEFORE WIN UPDATE:');
      print('Round: ${roomDataProvider.currentRound}/${roomDataProvider.maxRounds}');
      print('P1: ${roomDataProvider.player1.nickname} (${roomDataProvider.player1.playerType}) - ${roomDataProvider.player1.points}pts (${roomDataProvider.player1.socketID})');
      print('P2: ${roomDataProvider.player2.nickname} (${roomDataProvider.player2.playerType}) - ${roomDataProvider.player2.points}pts (${roomDataProvider.player2.socketID})');
      
      // Update room data first
      print('\n🔄 PROCESSING WIN UPDATE:');
      print('Room Data Turn: ${data['room']['turn']['nickname']} (${data['room']['turn']['playerType']})');
      print('Room Data Players:');
      (data['room']['players'] as List).forEach((p) {
        print('  ${p['nickname']} (${p['playerType']}): ${p['points']}pts (${p['socketID']})');
      });
      
      roomDataProvider.handleWin(data['room']);
      
      print('\n📊 STATE AFTER WIN UPDATE:');
      print('Round: ${roomDataProvider.currentRound}/${roomDataProvider.maxRounds}');
      print('P1: ${roomDataProvider.player1.nickname} (${roomDataProvider.player1.playerType}) - ${roomDataProvider.player1.points}pts');
      print('P2: ${roomDataProvider.player2.nickname} (${roomDataProvider.player2.playerType}) - ${roomDataProvider.player2.points}pts');
      
      // Check if this is the last round
      bool isLastRound = data['isLastRound'] ?? false;
      print('\n🔍 ROUND STATUS:');
      print('Current Round: ${roomDataProvider.currentRound}');
      print('Max Rounds: ${roomDataProvider.maxRounds}');
      print('Is Last Round: $isLastRound');
      
      if (!isLastRound) {
        print('\n🎯 Round Complete - Resetting game');
        roomDataProvider.resetGame();
      } else {
        print('\n⏳ LAST ROUND WON - Waiting for final scores...');
      }
    });

    // Listener for game end
    _socketClient.on('gameEnd', (data) {
      if (!context.mounted) return;
      
      print('\n🏁 GAME END EVENT RECEIVED:');
      print('----------------------------------------');
      print('Final Winner Socket ID: ${data['winnerSocketId']}');
      
      var roomDataProvider = Provider.of<RoomDataProvider>(context, listen: false);
      
      print('\n📊 FINAL STATE BEFORE UPDATE:');
      print('Round: ${roomDataProvider.currentRound}/${roomDataProvider.maxRounds}');
      print('P1: ${roomDataProvider.player1.nickname} (${roomDataProvider.player1.playerType}) - ${roomDataProvider.player1.points}pts (${roomDataProvider.player1.socketID})');
      print('P2: ${roomDataProvider.player2.nickname} (${roomDataProvider.player2.playerType}) - ${roomDataProvider.player2.points}pts (${roomDataProvider.player2.socketID})');
      
      print('\n📊 RECEIVED FINAL SCORES:');
      if (data['finalScores'] != null) {
        for (var score in data['finalScores']) {
          print('${score['nickname']} (${score['playerType']}): ${score['points']}pts (${score['socketID']})');
          
          // Update player points directly from final scores
          if (roomDataProvider.player1.socketID == score['socketID']) {
            print('Updating P1 points: ${roomDataProvider.player1.points} -> ${score['points']}');
            roomDataProvider.player1.points = score['points'];
          } else if (roomDataProvider.player2.socketID == score['socketID']) {
            print('Updating P2 points: ${roomDataProvider.player2.points} -> ${score['points']}');
            roomDataProvider.player2.points = score['points'];
          }
        }
      } else {
        print('⚠️ No final scores received!');
      }
      
      print('\n🔄 PROCESSING FINAL ROOM UPDATE');
      print('Room Data Players:');
      (data['room']['players'] as List).forEach((p) {
        print('  ${p['nickname']} (${p['playerType']}): ${p['points']}pts (${p['socketID']})');
      });
      
      // Update room data with final state
      roomDataProvider.handleWin(data['room']);
      
      print('\n📊 FINAL STATE AFTER UPDATE:');
      print('Round: ${roomDataProvider.currentRound}/${roomDataProvider.maxRounds}');
      print('P1: ${roomDataProvider.player1.nickname} (${roomDataProvider.player1.playerType}) - ${roomDataProvider.player1.points}pts');
      print('P2: ${roomDataProvider.player2.nickname} (${roomDataProvider.player2.playerType}) - ${roomDataProvider.player2.points}pts');
      
      print('\n🔄 Navigating to game over screen');
      // Navigate to game over screen
      Navigator.pushNamedAndRemoveUntil(
        context,
        GameOverScreen.routeName,
        (route) => false,
      );
    });
  }


  void tappedListener(BuildContext context) {
    print('\n🎮 Setting up tapped listener');
    _socketClient.off('tapped');
    
    _socketClient.on('tapped', (data) {
      print('\n🎯 TAP EVENT RECEIVED:');
      print('----------------------------------------');
      print('Data: $data');
      
      if (!context.mounted) {
        print('❌ Context not mounted, skipping tap');
        return;
      }
      
      try {
        RoomDataProvider roomDataProvider = Provider.of<RoomDataProvider>(context, listen: false);
        
        print('\nProcessing tap event:');
        print('Index: ${data['index']}');
        print('Choice: ${data['choice']}');
        print('Current board: ${roomDataProvider.displayElements}');
        
        // Update board state
        roomDataProvider.updateDisplayElements(
          data['index'],
          data['choice'],
        );
        
        // Update room data
        if (data['room'] != null) {
          roomDataProvider.updateRoomData(Map<String, dynamic>.from(data['room']));
        }
        
        print('\nAfter update:');
        print('Board: ${roomDataProvider.displayElements}');
        print('Turn: ${roomDataProvider.roomData['turn']['nickname']}');
        
        // Check for winner
        _gameMethods.checkWinner(context, _socketClient);
      } catch (e) {
        print('\n❌ Error handling tap:');
        print('Error: $e');
      }
      print('----------------------------------------');
    });
    print('✅ Tapped listener setup complete');
  }

  void restartGame(String roomId) {
    print('\n🔄 REQUESTING GAME RESTART:');
    print('Room ID: $roomId');
    print('Socket connected: ${_socketClient.connected}');
    print('Socket ID: ${_socketClient.id}');
    
    _socketClient.emit('restart_game', {
      'roomId': roomId,
    });
  }

  void gameRestartedListener(BuildContext context) {
    print('\n🎮 Setting up gameRestarted listener');
    _socketClient.off('gameRestarted');

    _socketClient.on('gameRestarted', (room) {
      print('\n🔄 GAME RESTART EVENT RECEIVED:');
      print('----------------------------------------');
      print('Room ID: ${room['_id']}');
      print('Round: ${room['currentRound']}');
      print('Turn: ${room['turn']['nickname']} (${room['turn']['playerType']})');
      print('Turn Index: ${room['turnIndex']}');
      print('Players: ${room['players']?.length ?? 0}');

      if (!context.mounted) {
        print('❌ Context not mounted, skipping restart');
        return;
      }

      try {
        print('\n🔄 Processing restart event:');
        final roomDataProvider = Provider.of<RoomDataProvider>(context, listen: false);
        
        print('Current room state:');
        print('Round: ${roomDataProvider.currentRound}');
        print('Turn: ${roomDataProvider.roomData['turn']?['nickname']}');
        print('Points - P1: ${roomDataProvider.player1.points}, P2: ${roomDataProvider.player2.points}');
        
        // First update room data
        final updatedRoom = Map<String, dynamic>.from(room);
        roomDataProvider.updateRoomData(updatedRoom);
        
        // Then reset game board
        roomDataProvider.resetGame();
        
        print('\nUpdated room state:');
        print('Round: ${roomDataProvider.currentRound}');
        print('Turn: ${roomDataProvider.roomData['turn']?['nickname']} (${roomDataProvider.roomData['turn']?['playerType']})');
        print('Turn Socket ID: ${roomDataProvider.roomData['turn']?['socketID']}');
        print('Current Socket ID: ${_socketClient.id}');
        print('Points - P1: ${roomDataProvider.player1.points}, P2: ${roomDataProvider.player2.points}');
        print('✅ Game state updated successfully');

        // Emit a room update to ensure all clients are in sync
        _socketClient.emit('updateRoom', {
          'roomId': room['_id'],
        });
      } catch (e) {
        print('\n❌ Error handling game restart:');
        print('Error: $e');
        print('Stack trace: ${StackTrace.current}');
      }
      print('----------------------------------------');
    });
    print('✅ gameRestarted listener setup complete');
  }

  void dispose() {
    _socketClient.off('createRoomSuccess');
    _socketClient.off('joinRoomSuccess');
    _socketClient.off('updateRoom');
    _socketClient.off('startGame');
    _socketClient.off('errorOccurred');
    _socketClient.off('tapped');
    _socketClient.off('gameWin');
    _socketClient.off('gameEnd');
    _socketClient.off('gameRestarted');
    _socketClient.off('draw');
  }
}