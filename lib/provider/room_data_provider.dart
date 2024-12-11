import 'package:flutter/material.dart';

class RoomDataProvider with ChangeNotifier {
  Map<String, dynamic> _roomData = {};
  int maxRounds = 3;
  int _currentRound = 1;

  Player _player1 = Player(nickname: '', socketID: '', playerType: '', points: 0);
  Player _player2 = Player(nickname: '', socketID: '', playerType: '', points: 0);

  List<String> _displayElements = List.generate(9, (_) => '');
  int _filledBoxes = 0;

  // Getters
  int get currentRound => _currentRound;
  Map<String, dynamic> get roomData => _roomData;
  Player get player1 => _player1;
  Player get player2 => _player2;
  List<String> get displayElements => _displayElements;
  int get filledBoxes => _filledBoxes;

  void updateRoomData(Map<String, dynamic> data) {
    _roomData = data;

    if (data['players']?.length == 2) {
      _player1 = Player.fromMap(data['players'][0]);
      _player2 = Player.fromMap(data['players'][1]);
    }

    if (data['currentRound'] != null) {
      _currentRound = data['currentRound'];
    }

    notifyListeners();
  }

  void handleWin(Map<String, dynamic> data) {
    if (data['players']?.length == 2) {
      _player1 = Player.fromMap(data['players'][0]);
      _player2 = Player.fromMap(data['players'][1]);
    }

    if (data['currentRound'] != null) {
      _currentRound = data['currentRound'];
    }

    notifyListeners();
  }

  void resetGame() {
    _displayElements = List.generate(9, (_) => '');
    _filledBoxes = 0;
    notifyListeners();
  }

  void resetAll() {
    _player1 = Player(nickname: _player1.nickname, socketID: _player1.socketID, playerType: _player1.playerType, points: 0);
    _player2 = Player(nickname: _player2.nickname, socketID: _player2.socketID, playerType: _player2.playerType, points: 0);
    resetGame();
  }

  void updateDisplayElements(int index, String value) {
    if (index >= 0 && index < _displayElements.length) {
      _displayElements[index] = value;
      _filledBoxes = _displayElements.where((e) => e.isNotEmpty).length;
      notifyListeners();
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
