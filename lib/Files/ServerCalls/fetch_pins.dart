import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:buff_lisa/Files/ServerCalls/restAPI.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import '../global.dart' as global;
class FetchPins {


  static Future<Set<Pin>> fetchGroupPins(Group group) async {
    HttpClientResponse response = await RestAPI.createHttpsRequest("/api/groups/${group.groupId}/pins", {}, 0, null);
    if (response.statusCode == 200) {
      return toPinSet(response, group);
    } else {
      throw Exception("Pins could not be loaded: ${response.statusCode} error code");
    }
  }

  static Future<Uint8List> fetchImageOfPin(Pin pin) async {
    HttpClientResponse response = await RestAPI.createHttpsRequest("/api/groups/${pin.group.groupId}/pins/${pin.id}/image", {}, 0, null);
    if (response.statusCode == 200) {
      return await ByteStream(response.cast()).toBytes();
    } else {
      throw Exception("failed to load mona");
    }
  }


  static Future<Pin> postPin(Pin mona) async {
    final String json = jsonEncode(<String, dynamic> {
      "latitude" : mona.latitude,
      "longitude" : mona.longitude,
      "groupId" : mona.group.groupId,
      "image": mona.image,
      "username": global.username,
    });
    final response =  await RestAPI.createHttpsRequest("/api/groups/${mona.group.groupId}/pins", {}, 1, json);
    if (response.statusCode == 201 || response.statusCode == 200) {
      final body = await response.transform(utf8.decoder).join();
      Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;
      return Pin.fromJson(json, mona.group);
    }
    throw Exception("Pin could not be created");
  }

  static Future<bool> deleteMonaFromPinId(int id) async {
    HttpClientResponse response = await RestAPI.createHttpsRequest("/api/groups/$id/pins", {}, 3, null);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    throw Exception("failed to delete pin");
  }

  //---------------------------------------

  static Future<Set<Pin>> toPinSet(HttpClientResponse response, Group group) async {
    List<dynamic> values = json.decode(await response.transform(utf8.decoder).join());

    Set<Pin> pins = {};
    for (var element in values) {
      pins.add(Pin.fromJson(element, group));

    }
    return pins;
  }
}