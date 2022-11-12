import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:buff_lisa/Files/DTOClasses/pin.dart';

import '../AbstractClasses/to_json.dart';

class Mona implements ToJson {
  final File image;
  final Pin pin;
  late int? groupId;

  Mona({
    required this.image,
    required this.pin
  });

  @override
  Future<Map<String, dynamic>> toJson() async {
    return {
      "groupId" : groupId,
      "pin": await pin.toJson(),
      "image": await image.readAsBytes()
    };
  }

  static Uint8List _getImageBinary(String dynamicList) {
    return base64Decode(dynamicList);
  }

  Mona.fromJson2(Map<String, dynamic> map) :
        image = File.fromRawPath(Uint8List.fromList(map['image'].cast<int>().toList())),
        pin = Pin.fromJson(map['pin']),
        groupId = map['groupId'];

  @override
  Mona.fromJson(Map<String, dynamic> map) :
        image = File.fromRawPath(_getImageBinary(map['image'])),
        pin = Pin.fromJson(map['pin']);

}