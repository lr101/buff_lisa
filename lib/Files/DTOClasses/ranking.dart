class Ranking {

  /// Username of the user [key]
  String username;

  /// points = number of post of the user [value]
  int points;

  /// Constructor
  Ranking( {
    required this.username,
    required this.points,
  });

  /// Constructor from json format
  Ranking.fromJson(Map<String,dynamic> map)
      : username = map['username'],
        points = map['points'];

  /// adds a point to the points when the user creates a new pin
  addOnePoint() {
    points++;
  }

  subOnePoint() {
    points--;
  }
}