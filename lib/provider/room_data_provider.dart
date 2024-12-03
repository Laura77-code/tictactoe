import 'package:flutter/material.dart';

class RoomDataProvider with ChangeNotifier {
  Map<String, dynamic> _roomData = {};
  int maxRounds = 3; // Number of rounds in the game
  int currentRound = 1; // Start with the first round

  Player _player1 = Player(nickname: '', socketID: '', playerType: '', points: 0);
  Player _player2 = Player(nickname: '', socketID: '', playerType: '', points: 0);

  List<String> _displayElements = List.generate(9, (_) => '');
  int _filledBoxes = 0;

  // Getters
  Map<String, dynamic> get roomData => _roomData;
  Player get player1 => _player1;
  Player get player2 => _player2;
  List<String> get displayElements => _displayElements;
  int get filledBoxes => _filledBoxes;

  // Update room data
  void updateRoomData(Map<String, dynamic> data) {
    _roomData = data;

    if (data['players']?.length == 2) {
      _player1 = Player.fromMap(data['players'][0]);
      _player2 = Player.fromMap(data['players'][1]);
    }

    // Skip updating the board if it has been reset
    if (_filledBoxes == 0 && _displayElements.every((e) => e.isEmpty)) {
      print('❗ Skipping board update as the game was reset.');
    } else if (data['board'] != null) {
      print('📋 Updating board from server data.');
      _displayElements = List<String>.from(data['board']);
      _filledBoxes = _displayElements.where((e) => e.isNotEmpty).length;
    }

    print('Room Data Updated:');
    print('Player 1: ${_player1.nickname} - Points: ${_player1.points}');
    print('Player 2: ${_player2.nickname} - Points: ${_player2.points}');
    notifyListeners();
  }

  // Update player1 data
  void updatePlayer1(Map<String, dynamic> playerData) {
    _player1 = Player.fromMap(playerData);
    notifyListeners();
  }

  // Update player2 data
  void updatePlayer2(Map<String, dynamic> playerData) {
    _player2 = Player.fromMap(playerData);
    notifyListeners();
  }

  // Reset the game board for the next round
  void resetGame() {
    _displayElements = List.generate(9, (_) => '');
    _filledBoxes = 0;
    print('Game reset for the next round.');
    notifyListeners();
  }

  // Reset the entire game, including points and rounds
  void resetAll() {
    currentRound = 1; // Reset to round 1
    resetGame(); // Clear the board
    _player1.points = 0;
    _player2.points = 0;
    print('Game fully reset.');
    notifyListeners();
  }

  // Increment the current round and ensure it does not exceed maxRounds
  void incrementRound() {
    if (currentRound < maxRounds) {
      currentRound += 1;
      print('🔄 Current Round: $currentRound');
      notifyListeners();
    }
  }

  // Update specific elements of the display board
  void updateDisplayElements(int index, String value) {
    if (index >= 0 && index < _displayElements.length) {
      _displayElements[index] = value;
      _filledBoxes = _displayElements.where((e) => e.isNotEmpty).length;
      notifyListeners();
      print('Updated Display Elements at index: $index with value: $value');
    } else {
      print('Index out of range for updating display elements.');
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
