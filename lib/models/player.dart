class Player {
  final String nickname;
  final String socketID;
  final int points;
  final String playerType;

  Player({
    required this.nickname,
    required this.socketID,
    required this.points,
    required this.playerType,
  });

  Map<String, dynamic> toMap() {
    return {
      'nickname': nickname,
      'socketID': socketID,
      'points': points,
      'playerType': playerType,
    };
  }

  factory Player.fromMap(Map<String, dynamic> data) {
    return Player(
      nickname: data['nickname'] ?? '',
      socketID: data['socketID'] ?? '',
      points: (data['points'] ?? 0).toInt(),
      playerType: data['playerType'] ?? '',
    );
  }
}