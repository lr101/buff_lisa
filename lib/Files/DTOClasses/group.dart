import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:buff_lisa/Files/AbstractClasses/to_json.dart';

import 'pin.dart';

class Group implements ToJson{
  final int groupId;
  final String name;
  final String? groupAdmin;
  final String? description;
  final File profileImage;
  final int visibility;
  final Set<String> members = {};
  final String? inviteUrl;
  late Set<Pin> pins = {};


  Group({
    required this.groupId,
    required this.name,
    required this.groupAdmin,
    required this.description,
    required this.profileImage,
    required this.visibility,
    required this.inviteUrl
  });

  Group.fromJson(Map<String, dynamic> json):
    groupId = json['groupId'],
    name = json['name'],
    groupAdmin = json['groupAdmin'],
    description = json['description'],
    profileImage = File.fromRawPath(_getImageBinary(json['profileImage'])),
    visibility = json['visibility'],
    inviteUrl = json['inviteUrl'];

  @override
  Future<Map<String, dynamic>> toJson() async {
    return {
      "groupId": groupId,
      "profileImage": await profileImage.readAsBytes(),
      "name" : name,
      "groupAdmin" : groupAdmin,
      "description" : description,
      "visibility" : visibility,
      "inviteUrl" : inviteUrl
    };
  }

  static Uint8List _getImageBinary(String dynamicList) {
    return base64Decode(dynamicList);
  }

}