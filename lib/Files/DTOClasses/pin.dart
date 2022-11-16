import '../AbstractClasses/to_json.dart';

class Pin implements ToJson {
  final double latitude;
  final double longitude;
  final int id;
  final DateTime creationDate;
  final String username;
  final int groupId;

  Pin( {
    required this.latitude,
    required this.longitude,
    required this.id,
    required this.creationDate,
    required this.username,
    required this.groupId
  });

  @override
  Pin.fromJson(Map<String, dynamic> json) :
        latitude = json['latitude'],
        longitude = json['longitude'],
        id = json['id'],
        username = json.containsKey('username') ? json['username'] : null,
        creationDate = DateTime.parse((json['creationDate']).toString()),
        groupId = json['groupId'];


  @override
  Future<Map<String, dynamic>> toJson() async {
    return {"longitude": longitude,
      "latitude": latitude,
      "id": id,
      "creationDate": formatDateTim(creationDate),
    };
  }

  static String formatDateTim(DateTime d) {
    DateTime date = DateTime(d.year, d.month, d.day);
    return date.toString().replaceAll(" 00:00:00.000", "");
  }

}

