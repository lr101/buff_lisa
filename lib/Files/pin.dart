import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';

class Pin {
  final double latitude;
  final double longitude;
  final int id;
  final Double distance;
  final DateTime creationDate;
  final SType type;

  const Pin({
    required this.latitude,
    required this.longitude,
    required this.id,
    required this.distance,
    required this.creationDate,
    required this.type,
  });

  Pin.fromJson(Map<String, dynamic> json) :
        latitude = json['latitude'],
        longitude = json['longitude'],
        id = json['id'],
        distance = Double(),
        type =  SType.fromJson(json['type']),
        creationDate = DateTime.parse((json['creationDate']).toString());

  Map<String, dynamic> toJson() {
    return {"longitude": longitude,
      "latitude": latitude,
      "id": id,
      "creationDate": formatDateTim(creationDate),
      "type": type.toJson()
    };
  }

  static String formatDateTim(DateTime d) {
    DateTime date = DateTime(d.year, d.month, d.day);
    return date.toString().replaceAll(" 00:00:00.000", "");
  }

}

class SType {
  final int id;
  final String name;

  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'name' : name
    };
  }

  SType({
    required this.id,
    required this.name
  });

  SType.fromJson(Map<String,dynamic> map)
      : id = map['id'],
        name = map['name'];

}

class Double {
  late double d = 0;
}

class Mona {
  final XFile image;
  final Pin pin;

  Mona({
    required this.image,
    required this.pin
  });

  Future<Map<String, dynamic>> toJson() async {
    return {"id": 0,
      "pin": pin.toJson(),
      "image": await image.readAsBytes()
    };
  }

  Mona.fromJson(Map<String,dynamic> map)
    : image = XFile.fromData(_getImageBinary(map['image'])),
      pin = Pin.fromJson(map['pin']);

  static Uint8List _getImageBinary(String dynamicList) {
    return base64Decode(dynamicList);
  }

}

class Version {
  final int id;
  final int pinId;
  final int type;

  Version( {
    required this.id,
    required this.type,
    required this.pinId
  });

  Version.fromJson(Map<String,dynamic> map)
      : id = map['id'],
        type = map['type'],
        pinId = map['pinId'];
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