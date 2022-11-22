import 'dart:convert';
import 'dart:typed_data';

import 'package:buff_lisa/Files/fetch_pins.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../AbstractClasses/to_json.dart';
import 'group.dart';

class Pin {
  final double latitude;
  final double longitude;
  final int id;
  final DateTime creationDate;
  final String username;
  final Group group;
  Uint8List? image;  //

  Pin( {
    required this.latitude,
    required this.longitude,
    required this.id,
    required this.creationDate,
    required this.username,
    required this.group,
    this.image
  });

  Pin.fromJson(Map<String, dynamic> json, this.group) :
      latitude = json['latitude'],
      longitude = json['longitude'],
      id = json['id'],
      username = json.containsKey('username') ? json['username'] : null,
      creationDate = DateTime.parse((json['creationDate']).toString()),
      image = null;

  Pin.fromJsonOffline(Map<String, dynamic> json, this.group) :
        latitude = json['latitude'],
        longitude = json['longitude'],
        id = json['id'],
        username = json.containsKey('username') ? json['username'] : null,
        creationDate = DateTime.parse((json['creationDate']).toString()),
        image = _getImageBinary(json['image']);


  Future<Map<String, dynamic>> toJson() async {
    return {
      "longitude": longitude,
      "latitude": latitude,
      "id": id,
      "creationDate": formatDateTim(creationDate),
      "username" : username
    };
  }

  Future<Map<String, dynamic>> toJsonOffline() async {
    return {
      "longitude": longitude,
      "latitude": latitude,
      "id": id,
      "creationDate": formatDateTim(creationDate),
      "username" : username,
      "image" : image,
      "groupId" : group.groupId
    };
  }


  static String formatDateTim(DateTime d) {
    DateTime date = DateTime(d.year, d.month, d.day);
    return date.toString().replaceAll(" 00:00:00.000", "");
  }

  static Uint8List _getImageBinary(String dynamicList) {
    return base64Decode(dynamicList);
  }

  Future<Uint8List> getImage() async {
    if (image != null) {
      return image!;
    } else {
      image = await FetchPins.fetchImageOfPin(this);
      return image!;
    }
  }
  Widget getImageWidget() {
    return FutureBuilder<Uint8List>(
      future: getImage(),
      builder: (context, snapshot) => snapshot.hasData ? Image.memory(snapshot.data!) : const CircularProgressIndicator(),
    );
  }

}

