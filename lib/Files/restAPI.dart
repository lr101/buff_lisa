import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:camera_camera/camera_camera.dart';
import 'package:flutter/services.dart';
import 'DTOClasses/mona.dart';
import 'DTOClasses/ranking.dart';
import 'global.dart' as global;

class RestAPI {

  static Future<List<Group>> fetchGroups() async {
    HttpClientResponse response = await createHttpsRequest("/api/users/${global.username}/groups" , {}, 0, null);
    if (response.statusCode == 200) {
      return toGroupList(response);
    } else {
      throw Exception("Groups could not be loaded: ${response.statusCode} error code");
    }
  }

  static Future<List<Group>> fetchAllGroups() async {
    HttpClientResponse response = await createHttpsRequest("/api/groups" , {}, 0, null);
    if (response.statusCode == 200) {
      return toGroupList(response);
    } else {
      throw Exception("Groups could not be loaded: ${response.statusCode} error code");
    }
  }

  static Future<Group?> postGroup(String name, String description, Uint8List image, int visibility) async {
    final String json = jsonEncode(<String, dynamic> {
      "name" : name,
      "groupAdmin": global.username,
      "description" : description,
      "profileImage": image,
      "visibility" : visibility
    });
    final response =  await createHttpsRequest("/api/groups", {}, 1, json);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Group.fromJson(jsonDecode(await response.transform(utf8.decoder).join()) as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  static Future<Set<Pin>> fetchGroupPins(int groupId) async {
    HttpClientResponse response = await createHttpsRequest("/api/groups/$groupId/pins", {}, 0, null);
    if (response.statusCode == 200) {
      return toPinSet(response, groupId);
    } else {
      throw Exception("Pins could not be loaded: ${response.statusCode} error code");
    }
  }

  static Future<Group> joinGroup(int groupId, String? inviteUrl) async {
    final String json = jsonEncode(<String, dynamic> {
      "username" : global.username,
      "inviteUrl" : inviteUrl
    });
    HttpClientResponse response = await createHttpsRequest("/api/groups/$groupId/members", {}, 1, json);
    if (response.statusCode == 200) {
      return Group.fromJson(jsonDecode(await response.transform(utf8.decoder).join()) as Map<String, dynamic>);
    } else {
      throw Exception("Group could not be joined: ${response.statusCode} error code");
    }
  }

  static Future<String?> checkUser(String? name) async {
    name ??= global.username;
    HttpClientResponse response = await createHttpsRequest("/login/$name/", {}, 0, null);
    if (response.statusCode == 200) {
      return await response.transform(utf8.decoder).join();
    }
    return null;
  }

  static Future<String?> checkUserToken(String? name, String password) async {
    final String json = jsonEncode(<String, dynamic>{
      "password" : password,
    });
    HttpClientResponse response = await createHttpsRequest("/token/$name/", {}, 2, json);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return await response.transform(utf8.decoder).join();
    }
    return null;
  }

  static Future<String?> auth(String? name, String password) async {
    final String json = jsonEncode(<String, dynamic>{
      "password" : password,
      "username" : name,
    });
    HttpClientResponse response = await createHttpsRequest("/login/", {}, 1, json);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return await response.transform(utf8.decoder).join();
    }
    return null;
  }

  static Future<bool> recover(String? name) async {
    HttpClientResponse response = await createHttpsRequest("/recover", {"username" : name}, 0, null);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  }

  static Future<String?> postUsername(String username, String hash, String email) async {
    final String json = jsonEncode(<String, dynamic>{
      "username" : username,
      "password" : hash,
      "email" : email
    });
    HttpClientResponse response = await createHttpsRequest("/signup/", {}, 1, json);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return await response.transform(utf8.decoder).join();
    }
    return null;
  }

  static Future<Mona?> fetchMonaFromPinId(int id, groupId) async {
    HttpClientResponse response = await createHttpsRequest("/api/monas/$id/", {}, 0, null);
    if (response.statusCode == 200) {
      Map<String, dynamic> map = json.decode(await response.transform(utf8.decoder).join());
      map['pin']['groupId'] = groupId;
      return Mona.fromJson(map);
    } else {
      throw Exception("failed to load mona");
    }
  }


  static Future<HttpClientResponse> postPin(Mona mona) async {
    final String json = jsonEncode(<String, dynamic> {
      "latitude" : mona.pin.latitude,
      "longitude" : mona.pin.longitude,
      "groupId" : mona.pin.groupId,
      "image": mona.image,
      "username": global.username,
    });
    return await createHttpsRequest("/api/monas/", {}, 1, json);
  }


  static Future<Pin?> fetchPin(int id, groupId) async {
    HttpClientResponse response = await createHttpsRequest("/api/pins/$id/", {}, 0, null);
    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(await response.transform(utf8.decoder).join()) as Map<String, dynamic>;
      if (json.isNotEmpty) {
        json['groupId'] = groupId;
        return Pin.fromJson(json);
      }
    }
    return null;
  }

  static Future<int?> getUserPoints() async {
    HttpClientResponse response = await createHttpsRequest("/api/users/${global.username}/points/", {}, 0, null);
    if (response.statusCode == 200) {
      return int.parse(await response.transform(utf8.decoder).join());
    }
    return null;
  }

  static Future<String?> getUsernameByPin(int id) async {
    HttpClientResponse response = await createHttpsRequest("/api/pins/$id/user/", {}, 0, null);
    if (response.statusCode == 200) {
      return await response.transform(utf8.decoder).join();
    }
    return null;
  }

  static Future<bool> changePassword(String username, String password) async {
    final String json = jsonEncode(<String, dynamic> {
      "password" : password
    });
    HttpClientResponse response = await createHttpsRequest("/api/users/$username/", {}, 2, json);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  static Future<bool> changeEmail(String username, String email) async {
    final String json = jsonEncode(<String, dynamic> {
      "email" : email
    });
    HttpClientResponse response = await createHttpsRequest("/api/users/$username/", {}, 2, json);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }


  static Future<bool> deleteMonaFromPinId(int id) async {
    HttpClientResponse response = await createHttpsRequest("/api/monas/$id", {}, 3, null);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  }

  static Future<Set<Pin>> toPinSet(HttpClientResponse response, groupId) async {
    List<dynamic> values = json.decode(await response.transform(utf8.decoder).join());

    Set<Pin> pins = {};
    for (var element in values) {
      element['groupId'] = groupId;
      pins.add(Pin.fromJson(element));
    }
    return pins;
  }

  static Future<List<Group>> toGroupList(HttpClientResponse response) async {
    List<dynamic> values = json.decode(await response.transform(utf8.decoder).join());

    List<Group> groups = [];
    for (var element in values) {
      groups.add(Group.fromJson(element));
    }
    return groups;
  }

  static Future<HttpClientResponse> createHttpsRequest (String path, Map<String,dynamic> queryParameters, int requestType, String? encode) async {
    SecurityContext context = SecurityContext(withTrustedRoots: true);
    context.setTrustedCertificatesBytes(utf8.encode(await rootBundle.loadString('images/cert.pem')), password: "password");
    HttpClient client = HttpClient(context: context) ..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    Uri url = Uri(scheme: "https", host: global.host, port: global.port, path: path, queryParameters: queryParameters);
    HttpClientRequest request;
    stderr.writeln(url);
    switch (requestType) {
      case 0: request = await client.getUrl(url);break;
      case 1: request = await client.postUrl(url);break;
      case 2: request = await client.putUrl(url);break;
      case 3: request = await client.deleteUrl(url);break;
      default: throw Exception("HTTPS Request method does not exist");
    }
    request.headers.add("Authorization", "Bearer ${global.token}");
    if (encode != null) {
      request.headers.contentType =  ContentType('application', 'json', charset: 'utf-8');
      request.write(encode);
    }
    print(request.uri.path);
    return await request.close();
  }

}

