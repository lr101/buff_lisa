class Ranking {
  final String username;
  final int points;

  Ranking( {
    required this.username,
    required this.points,
  });

  Ranking.fromJson(Map<String,dynamic> map)
      : username = map['username'],
        points = map['points'];

}