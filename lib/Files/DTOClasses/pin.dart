import 'dart:typed_data';

import 'package:buff_lisa/Files/AbstractClasses/async_type.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_pins.dart';
import 'package:flutter/material.dart';

import 'group.dart';

class Pin {

  /// latitude position of the pin
  final double latitude;

  /// longitude position of the pin
  final double longitude;

  /// unique id of the pin
  final int id;

  /// date of creation of the pin
  final DateTime creationDate;

  /// user that created the pin
  final String username;

  /// group the pin belongs to
  final Group group;

  /// Uint8List:  image as byte list of the pin
  /// null: not loaded from server yet
  late final AsyncType<Uint8List> image;

  bool isOffline;

  /// Constructor of pin
  Pin( {
    required this.latitude,
    required this.longitude,
    required this.id,
    required this.creationDate,
    required this.username,
    required this.group,
    this.isOffline = false,
    Uint8List? image
  }) {
    this.image = AsyncType<Uint8List>(value: image, callback: () => FetchPins.fetchImageOfPin(this), builder: (_) => Image.memory(_));
  }

  /// Constructor of pin from json when pin is loaded from server
  static Pin fromJson(Map<String, dynamic> json, group) {
    return Pin(
        latitude : json['latitude'],
        longitude : json['longitude'],
        id : json['id'],
        username : json.containsKey('username') ? json['username'] : json.containsKey('creationUser') ? json['creationUser'] : "",
        creationDate : DateTime.parse((json['creationDate']).toString()),
        group: group,
        isOffline : false
    );
  }


  /// returns json format for posting pin to server
  Future<Map<String, dynamic>> toJson() async {
    return {
      "longitude": longitude,
      "latitude": latitude,
      "id": id,
      "creationDate": formatDateTim(creationDate),
      "username" : username
    };
  }

  /// format DateTime object to string
  static String formatDateTim(DateTime d) {
    DateTime date = DateTime(d.year, d.month, d.day);
    return date.toString();
  }

}

