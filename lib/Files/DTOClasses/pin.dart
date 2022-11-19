import '../AbstractClasses/to_json.dart';
import 'group.dart';

class Pin implements ToJson {
  final double latitude;
  final double longitude;
  final int id;
  final DateTime creationDate;
  final String username;
  Group group;

  Pin( {
    required this.latitude,
    required this.longitude,
    required this.id,
    required this.creationDate,
    required this.username,
    required this.group
  });

  @override
  Pin.fromJson(Map<String, dynamic> json, this.group) :
        latitude = json['latitude'],
        longitude = json['longitude'],
        id = json['id'],
        username = json.containsKey('username') ? json['username'] : null,
        creationDate = DateTime.parse((json['creationDate']).toString());


  @override
  Future<Map<String, dynamic>> toJson() async {
    return {
      "longitude": longitude,
      "latitude": latitude,
      "id": id,
      "creationDate": formatDateTim(creationDate),
      "username" : username
    };
  }

  static String formatDateTim(DateTime d) {
    DateTime date = DateTime(d.year, d.month, d.day);
    return date.toString().replaceAll(" 00:00:00.000", "");
  }

}

