import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:buff_lisa/Files/ServerCalls/restAPI.dart';
import 'package:http/http.dart';

import '../Other/global.dart' as global;
class FetchPins {

  /// returns a set of all pins contained in a [group]
  /// throws an Exception if an error occurs
  /// GET Request to Server
  static Future<Set<Pin>> fetchGroupPins(Group group) async {
    Response response = await RestAPI.createHttpsRequest("/api/groups/${group.groupId}/pins", {}, 0);
    if (response.statusCode == 200) {
      return toPinSet(response, group);
    } else {
      throw Exception("Pins could not be loaded: ${response.statusCode} error code");
    }
  }

  /// returns a set of all pins of the currently logged-in user
  /// throws an Exception if an error occurs
  /// GET Request to Server
  static Future<List<int>> fetchUserPins() async {
    Response response = await RestAPI.createHttpsRequest("/api/users/${global.username}/pins", {}, 0);
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List<dynamic>).map((e) => e as int).toList();
    } else {
      throw Exception("Pins could not be loaded: ${response.statusCode} error code");
    }
  }

  /// returns a set of all pins of the currently logged-in user
  /// throws an Exception if an error occurs
  /// GET Request to Server
  static Future<Pin> fetchUserPin(int pinId) async {
    Response response = await RestAPI.createHttpsRequest("/api/pins/$pinId", {}, 0);
    if (response.statusCode == 200) {
      return Pin.fromJson(json.decode(response.body), Group(groupId: -1,name: "default", visibility: 0, inviteUrl: null));
    } else {
      throw Exception("Pins could not be loaded: ${response.statusCode} error code");
    }
  }

  /// returns the image of a pin as a byte list that is identified by [pin]
  /// throws an Exception if an error occurs
  /// GET Request to Server
  static Future<Uint8List> fetchImageOfPin(Pin pin) async {
    Response response = await RestAPI.createHttpsRequest("/api/pins/${pin.id}/image", {}, 0,);
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception("failed to load mona");
    }
  }


  /// returns the image of a pin as byte list saved as blob in browser
  /// throws an Exception if an error occurs
  /// GET Request to local cash
  static Future<Uint8List> fetchImageFromBrowserCash(String url) async {
    Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception("failed to load mona");
    }
  }


  /// this method creates a pin by posting the existing information of a pin, contained in [pin], to the server
  /// returns the pin that is returned by the server
  /// throws an Exception if an error occurs
  /// POST Request to Server
  static Future<Pin> postPin(Pin mona) async {
    final String json = jsonEncode(<String, dynamic> {
      "latitude" : mona.latitude,
      "longitude" : mona.longitude,
      "groupId" : mona.group.groupId,
      "image": mona.image,
      "username": global.username,
    });
    final response =  await RestAPI.createHttpsRequest("/api/pins", {}, 1, encode:  json);
    if (response.statusCode == 201 || response.statusCode == 200) {
      final body = response.body;
      Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;
      return Pin.fromJson(json, mona.group);
    }
    throw Exception("Pin could not be created");
  }

  /// deletes a pin on the server identified by [id]
  /// throws an Exception if an error occurs
  /// GET Request to Server
  static Future<bool> deleteMonaFromPinId(int id) async {
    Response response = await RestAPI.createHttpsRequest("/api/pins", {}, 3);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    throw Exception("failed to delete pin");
  }

  //---------------------------------------

  /// converts a client response to a pin set
  static Future<Set<Pin>> toPinSet(Response response, Group group) async {
    List<dynamic> values = json.decode(response.body);

    Set<Pin> pins = {};
    for (var element in values) {
      pins.add(Pin.fromJson(element, group));

    }
    return pins;
  }
}