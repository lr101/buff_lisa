import 'dart:convert';
import 'dart:typed_data';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:hive/hive.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_pins.dart';
import 'package:flutter/material.dart';
import 'group.dart';

part 'pinDTO.g.dart';

@HiveType(typeId: 0)
class PinDTO {

  /// latitude position of the pin
  @HiveField(0)
  final double latitude;

  /// longitude position of the pin
  @HiveField(1)
  final double longitude;

  /// unique id of the pin
  @HiveField(2)
  final int id;

  /// date of creation of the pin
  @HiveField(3)
  final DateTime creationDate;

  /// user that created the pin
  @HiveField(4)
  final String username;

  /// group the pin belongs to
  @HiveField(5)
  final int groupId;

  /// Uint8List:  image as byte list of the pin
  /// null: not loaded from server yet
  @HiveField(6)
  Uint8List? image;

  PinDTO({
    required this.latitude,
    required this.longitude,
    required this.id,
    required this.creationDate,
    required this.username,
    required this.groupId,
    required this.image
  });

  PinDTO.fromPin(Pin pin) :
        latitude = pin.latitude,
        longitude = pin.longitude,
        id = pin.id,
        creationDate = pin.creationDate,
        username = pin.username,
        groupId = pin.group.groupId,
        image = pin.image.syncValue;

  Pin? toPin(Group group) {
    if (group.groupId == groupId) {
      return Pin(id: id, creationDate: creationDate, group: group, latitude: latitude, longitude: longitude, username: username,image: image);
    }
    return null;
  }


}

