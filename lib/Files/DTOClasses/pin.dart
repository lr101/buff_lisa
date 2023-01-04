import 'dart:convert';
import 'dart:typed_data';

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
  Uint8List? image;

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
    this.image
  });

  /// Constructor of pin from json when pin is loaded from server
  Pin.fromJson(Map<String, dynamic> json, this.group) :
      latitude = json['latitude'],
      longitude = json['longitude'],
      id = json['id'],
      username = json.containsKey('username') ? json['username'] : null,
      creationDate = DateTime.parse((json['creationDate']).toString()),
      isOffline = false,
      image = null;

  /// Constructor of pin from json when pin is loaded from offline storage
  Pin.fromJsonOffline(Map<String, dynamic> json, this.group) :
        latitude = json['latitude'],
        longitude = json['longitude'],
        id = json['id'],
        username = json.containsKey('username') ? json['username'] : null,
        creationDate = DateTime.parse((json['creationDate']).toString()),
        isOffline = true,
        image = _getImageBinary(json['image']);


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

  /// returns json format for saving pin offline
  Future<Map<String, dynamic>> toJsonOffline() async {
    return {
      "longitude": longitude,
      "latitude": latitude,
      "id": id,
      "creationDate": formatDateTim(creationDate),
      "username" : username,
      "image" : base64Encode(image!.toList()),
      "groupId" : group.groupId
    };
  }

  /// format DateTime object to string
  static String formatDateTim(DateTime d) {
    DateTime date = DateTime(d.year, d.month, d.day);
    return date.toString().replaceAll(" 00:00:00.000", "");
  }

  /// decodes a base64 encoded image to a byte list
  static Uint8List _getImageBinary(String dynamicList) {
    return base64Decode(dynamicList);
  }

  /// returns the pin image byte data from local if existing or server
  Future<Uint8List> getImage() async {
    if (image != null) {
      return image!;
    } else {
      image = await FetchPins.fetchImageOfPin(this);
      return image!;
    }
  }

  /// returns the pin image as Image Widget from local if existing or server
  Widget getImageWidget() {
    return FutureBuilder<Uint8List>(
      future: getImage(),
      builder: (context, snapshot) => snapshot.hasData ? Image.memory(snapshot.data!) : const CircularProgressIndicator(),
    );
  }

}

