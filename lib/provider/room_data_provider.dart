import 'package:flutter/material.dart';

class RoomDataProvider with ChangeNotifier {
  Map<String, dynamic> _roomData = {};
  int _maxRounds = 3;
  int _currentRound = 1;
  bool _isGameOver = false;

  Player _player1 = Player(nickname: '', socketID: '', playerType: '', points: 0);
  Player _player2 = Player(nickname: '', socketID: '', playerType: '', points: 0);

  List<String> _displayElements = List.generate(9, (_) => '');
  int _filledBoxes = 0;

  // Getters
  int get currentRound => _currentRound;
  int get maxRounds => _maxRounds;
  Map<String, dynamic> get roomData => _roomData;
  Player get player1 => _player1;
  Player get player2 => _player2;
  List<String> get displayElements => _displayElements;
  int get filledBoxes => _filledBoxes;
  bool get isGameOver => _isGameOver;

  void updateRoomData(Map<String, dynamic> data) {
    print('\n📊 UPDATING ROOM DATA:');
    print('----------------------------------------');
    print('Current room state:');
    print('Room ID: ${_roomData['_id']}');
    print('Round: $_currentRound');
    print('Turn: ${_roomData['turn']?['nickname']}');
    print('Board: $_displayElements');
    
    _roomData = data;
    _maxRounds = data['maxRounds'];
    
    if (data['players'] != null && data['players'].length == 2) {
      print('\nProcessing Players:');
      _player1 = Player.fromMap(data['players'][0]);
      _player2 = Player.fromMap(data['players'][1]);
      print('P1: ${_player1.nickname} (${_player1.playerType}) - ${_player1.points}pts');
      print('P2: ${_player2.nickname} (${_player2.playerType}) - ${_player2.points}pts');
    }

    if (data['currentRound'] != null) {
      _currentRound = data['currentRound'];
      print('\nRound updated: $_currentRound/$_maxRounds');
    }

    if (data['turn'] != null) {
      print('\nTurn updated:');
      print('Player: ${data['turn']['nickname']}');
      print('Type: ${data['turn']['playerType']}');
      print('Socket: ${data['turn']['socketID']}');
    }

    if (data['board'] != null) {
      print('\nBoard updated:');
      print('Old board: $_displayElements');
      _displayElements = List<String>.from(data['board']);
      print('New board: $_displayElements');
    }

    print('\nFinal state:');
    print('Room ID: ${_roomData['_id']}');
    print('Round: $_currentRound');
    print('Turn: ${_roomData['turn']?['nickname']}');
    print('Board: $_displayElements');
    print('----------------------------------------');
    
    notifyListeners();
  }

  void handleWin(Map<String, dynamic> data) {
    print('\n🏆 HANDLING WIN EVENT:');
    print('----------------------------------------');
    
    try {
      print('\n📊 CURRENT STATE:');
      print('Round: $_currentRound/$_maxRounds');
      print('Game Over: $_isGameOver');
      print('P1 Points: ${_player1.points}');
      print('P2 Points: ${_player2.points}');

      // Update scores first
      if (data['players']?.length == 2) {
        print('\n🔄 UPDATING PLAYERS:');
        var oldP1Points = _player1.points;
        var oldP2Points = _player2.points;
        
        _player1 = Player.fromMap(data['players'][0]);
        _player2 = Player.fromMap(data['players'][1]);
        
        print('\nPlayers after update:');
        print('P1: ${_player1.points} (${_player1.points - oldP1Points > 0 ? "+1" : "0"})');
        print('P2: ${_player2.points} (${_player2.points - oldP2Points > 0 ? "+1" : "0"})');
      }

      // Update round - Asegurarse de que el incremento sea correcto
      if (data['currentRound'] != null) {
        print('\n🎲 ROUND UPDATE:');
        print('Current round: $_currentRound');
        _currentRound = data['currentRound'];
        print('New round: $_currentRound');
        print('Rounds remaining: ${_maxRounds - _currentRound}');
      }

      // Check for game over
      if (_currentRound > _maxRounds) {
        _currentRound = _maxRounds; // Asegurarse de no exceder el máximo
      }
      
      if (_currentRound >= _maxRounds) {
        _isGameOver = true;
        print('\n🏁 GAME OVER:');
        print('Final Scores:');
        print('  ▸ ${_player1.nickname}: ${_player1.points}pts');
        print('  ▸ ${_player2.nickname}: ${_player2.points}pts');
        print('  ▸ Winner: ${_player1.points > _player2.points ? _player1.nickname : _player2.nickname}');
      }

      notifyListeners();

    } catch (e, stackTrace) {
      print('\n❌ ERROR handling win:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
    }
    print('----------------------------------------');
  }

  void resetGame() {
    print('\n🔄 RESETTING GAME BOARD:');
    print('----------------------------------------');
    print('Before reset:');
    print('Board: $_displayElements');
    print('Filled boxes: $_filledBoxes');
    
    setState(() {
      _displayElements = ['', '', '', '', '', '', '', '', ''];
      _filledBoxes = 0;
    });
    
    print('\nAfter reset:');
    print('Board: $_displayElements');
    print('Filled boxes: $_filledBoxes');
    print('----------------------------------------');
  }

  void resetAll() {
    print('\n🔄 Resetting all game state:');
    print('Before reset:');
    print('Round: $_currentRound');
    print('Points - P1: ${_player1?.points}, P2: ${_player2?.points}');

    _displayElements = ['', '', '', '', '', '', '', '', ''];
    _filledBoxes = 0;
    _currentRound = 1;
    _maxRounds = 3;
    _isGameOver = false;
    
    if (_player1 != null) _player1!.points = 0;
    if (_player2 != null) _player2!.points = 0;
    
    print('\nAfter reset:');
    print('Round: $_currentRound');
    print('Points - P1: ${_player1?.points}, P2: ${_player2?.points}');
    
    notifyListeners();
  }

  void updateDisplayElements(int index, String choice) {
    print('\n🎯 UPDATING DISPLAY ELEMENTS:');
    print('----------------------------------------');
    print('Index: $index');
    print('Choice: $choice');
    print('Before update: $_displayElements');
    
    if (index >= 0 && index < _displayElements.length) {
      _displayElements[index] = choice;
      _filledBoxes += 1;
      
      print('\nAfter update:');
      print('Board: $_displayElements');
      print('Filled boxes: $_filledBoxes');
      notifyListeners();
    } else {
      print('❌ Invalid index: $index');
    }
    print('----------------------------------------');
  }

  void setState(Function() fn) {
    try {
      print('\n🔄 UPDATING STATE:');
      fn();
      print('✅ State updated successfully');
      notifyListeners();
      print('✅ Listeners notified');
    } catch (e, stack) {
      print('\n❌ Error updating state:');
      print('Error: $e');
      print('Stack trace: $stack');
    }
  }
}

// Player model for storing player data
class Player {
  String nickname;
  String socketID;
  String playerType;
  int points;

  Player({
    required this.nickname,
    required this.socketID,
    required this.playerType,
    required this.points,
  });

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      nickname: map['nickname'] ?? '',
      socketID: map['socketID'] ?? '',
      playerType: map['playerType'] ?? '',
      points: map['points'] ?? 0,
    );
  }
}
