import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class Pin implements ToJson {
  final double latitude;
  final double longitude;
  final int id;
  final DateTime creationDate;
  final SType type;
  final String? username;

  const Pin({
    required this.latitude,
    required this.longitude,
    required this.id,
    required this.creationDate,
    required this.type,
    required this.username
  });

  @override
  Pin.fromJson(Map<String, dynamic> json) :
        latitude = json['latitude'],
        longitude = json['longitude'],
        id = json['id'],
        type =  SType.fromJson(json['type']),
        username = json.containsKey('username') ? json['username'] : null,
        creationDate = DateTime.parse((json['creationDate']).toString());


  @override
  Future<Map<String, dynamic>> toJson() async {
    return {"longitude": longitude,
      "latitude": latitude,
      "id": id,
      "creationDate": formatDateTim(creationDate),
      "type": await type.toJson()
    };
  }

  static String formatDateTim(DateTime d) {
    DateTime date = DateTime(d.year, d.month, d.day);
    return date.toString().replaceAll(" 00:00:00.000", "");
  }

}

class SType implements ToJson{
  final int id;
  final String name;

  @override
  Future<Map<String, dynamic>> toJson() async {
    return {
      'id' : id,
      'name' : name
    };
  }

  SType({
    required this.id,
    required this.name
  });

  @override
  SType.fromJson(Map<String, dynamic> map) :
    id = map['id'],
    name = map['name'];

}
class Mona implements ToJson {
  final File image;
  final Pin pin;

  Mona({
    required this.image,
    required this.pin
  });

  @override
  Future<Map<String, dynamic>> toJson() async {
    return {
      "id": 0,
      "pin": await pin.toJson(),
      "image": await image.readAsBytes()
    };
  }

  static Uint8List _getImageBinary(String dynamicList) {
    return base64Decode(dynamicList);
  }

  Mona.fromJson2(Map<String, dynamic> map) :
        image = File.fromRawPath(Uint8List.fromList(map['image'].cast<int>().toList())),
        pin = Pin.fromJson(map['pin']);

  @override
  Mona.fromJson(Map<String, dynamic> map) :
        image = File.fromRawPath(_getImageBinary(map['image'])),
        pin = Pin.fromJson(map['pin']);

}

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

abstract class ToJson {
  ToJson.fromJson(Map<String, dynamic> map);
  Future<Map<String, dynamic>> toJson();
}