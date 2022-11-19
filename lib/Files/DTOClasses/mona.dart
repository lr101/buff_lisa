import 'dart:convert';
import 'dart:typed_data';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import '../AbstractClasses/to_json.dart';
import 'group.dart';

class Mona implements ToJson {
  final Uint8List image;
  final Pin pin;

  Mona({
    required this.image,
    required this.pin
  });

  @override
  Future<Map<String, dynamic>> toJson() async {
    return {
      "pin": await pin.toJson(),
      "image": image
    };
  }

  static Uint8List _getImageBinary(String dynamicList) {
    return base64Decode(dynamicList);
  }

  Mona.fromJson2(Map<String, dynamic> map, Group group) :
        image = Uint8List.fromList(map['image'].cast<int>().toList()),
        pin = Pin.fromJson(map['pin'], group);
  @override
  Mona.fromJson(Map<String, dynamic> map, Group group) :
        image = _getImageBinary(map['image']),
        pin = Pin.fromJson(map['pin'], group);

}