import 'dart:convert';
import 'dart:typed_data';

import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/ServerCalls/fetch_groups.dart';
import 'package:buff_lisa/Files/ServerCalls/restAPI.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
class FetchPins {

  /// returns a set of all pins contained in a [group]
  /// throws an Exception if an error occurs
  /// GET Request to Server
  static Future<Set<Pin>> fetchGroupPins(Group group) async {
    Response response = await RestAPI.createHttpsRequest("/api/groups/${group.groupId}/pins", {}, 0,timeout: 20);
    if (response.statusCode == 200) {
      return toPinSet(response, group);
    } else {
      throw Exception("Pins could not be loaded: ${response.statusCode} error code");
    }
  }

  /// returns a set of pins the currently logged in user has access to (in the same group) from the requested user
  /// throws an Exception if an error occurs
  /// GET Request to Server
  static Future<List<Pin>> fetchUserPins(String username, List<Group> groups, Future<Group> Function(int id, List<Group>) getGroup) async {
    Response response = await RestAPI.createHttpsRequest("/api/users/$username/pins", {}, 0);
    if (response.statusCode == 200) {
      return toPinList(response, groups, getGroup);
    } else {
      throw Exception("Pins could not be loaded: ${response.statusCode} error code");
    }
  }

  /// returns a set of all pins of the currently logged-in user
  /// throws an Exception if an error occurs
  /// GET Request to Server
  static Future<Pin> fetchUserPin(int pinId, List<Group> userGroups) async {
    Response response = await RestAPI.createHttpsRequest("/api/pins/$pinId", {}, 0);
    if (response.statusCode == 200) {
      Map<String,dynamic> map = json.decode(response.body);
      Group group = userGroups.firstWhere((element) => element.groupId == map["group"]["groupId"], orElse: () => Group.fromJson( map["group"]));
      return Pin.fromJson(map["pin"], group);
    } else {
      throw Exception("Pins could not be loaded: ${response.statusCode} error code");
    }
  }


  static Future<Set<Pin>> fetchUserPinsOfGroup(String username, Group group) async {
    Response response = await RestAPI.createHttpsRequest("/api/users/$username/pins/${group.groupId}", {}, 0);
    if (response.statusCode == 200) {
      return toPinSet(response, group);
    } else {
      throw Exception("Pins could not be loaded: ${response.statusCode} error code");
    }
  }
  /// returns the image of a pin as a byte list that is identified by [pin]
  /// throws an Exception if an error occurs
  /// GET Request to Server
  static Future<Uint8List> fetchImageOfPin(Pin pin, [String? compression, String? height]) async {
    Map<String, String> queryParams = {};
    if (compression != null) queryParams["compression"] = compression;
    if (height != null) queryParams["height"] = height;
    Response response = await RestAPI.createHttpsRequest("/api/pins/${pin.id}/image", queryParams, 0,);
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception("failed to load mona");
    }
  }

  static Future<void> fetchPreviewsOfPins(List<Pin> pins, [int? height, int? compression]) async {
    String ids = "";
    List<Pin> filtered = pins.where((element) => element.preview.isEmpty).toList();
    for (Pin pin in filtered) {
      ids += pin.id.toString();
      ids+="-";
    }
    if (ids == "") return;
    ids = ids.substring(0, ids.length - 1);
    Map<String, String> queryParams = {"ids" : ids};
    if (height != null) queryParams["height"] = height.toString();
    if (compression != null) queryParams["compression"] = compression.toString();
    Response response = await RestAPI.createHttpsRequest("/api/images", queryParams, 0,timeout: 60);
    if (response.statusCode == 200) {
      List<dynamic> list = json.decode(response.body);
      for(int i = 0; i < filtered.length; i++) {
        try {
          filtered[i].preview.setValue(base64Decode(list[i]));
        } catch(_) {}
      }
    } else {
      throw Exception("failed to load monas");
    }
  }
  static Future<void> fetchImagesOfPins(List<Pin> pins, [int? compression]) async {
    String ids = "";
    List<Pin> filtered = pins.where((element) => element.image.isEmpty).toList();
    for (Pin pin in filtered) {
      ids += pin.id.toString();
      ids+="-";
    }
    if (ids == "") return;
    ids = ids.substring(0, ids.length - 1);
    Map<String, String> queryParams = {"ids" : ids};
    if (compression != null) queryParams["compression"] = compression.toString();
    Response response = await RestAPI.createHttpsRequest("/api/images", queryParams, 0,timeout: 60);
    if (response.statusCode == 200) {
      List<dynamic> list = json.decode(response.body);
      for(int i = 0; i < filtered.length; i++) {
        try {
          filtered[i].image.setValue(base64Decode(list[i]));
        } catch(_) {}
      }
    } else {
      throw Exception("failed to load monas");
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
      "image": mona.image.syncValue,
      "username": global.localData.username,
      "creationDate": mona.creationDate.toIso8601String()
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
    Response response = await RestAPI.createHttpsRequest("/api/pins/$id", {}, 3);
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

  /// converts a client response to a pin list
  static Future<List<Pin>> toPinList(Response response, List<Group> groups, Future<Group> Function(int id, List<Group>) getGroup) async {
    List<dynamic> values = json.decode(response.body);
    List<Pin> pins = [];
    for (var element in values) {
      pins.add(Pin.fromJson(element, await getGroup(element["groupId"] as int, groups)));
    }
    return pins;
  }
}