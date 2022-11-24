import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:buff_lisa/Files/restAPI.dart';
import 'package:flutter/services.dart';
import 'DTOClasses/ranking.dart';
import 'global.dart' as global;
class FetchUsers {
  static Future<List<Ranking>> fetchGroupMembers(Group group) async {
    HttpClientResponse response = await RestAPI.createHttpsRequest("/api/groups/${group.groupId}/members" , {}, 0, null);
    if (response.statusCode == 200) {
      List<Ranking> members = [];
      List<dynamic> values = json.decode(await response.transform(utf8.decoder).join());
      for (dynamic d in values) {
        members.add(Ranking.fromJson(d));
      }
      return members;
    } else {
      throw Exception("Groups could not be loaded: ${response.statusCode} error code");
    }
  }

  static Future<String?> checkUser(String? name) async {
    name ??= global.username;
    HttpClientResponse response = await RestAPI.createHttpsRequest("/login/$name/", {}, 0, null);
    if (response.statusCode == 200) {
      return await response.transform(utf8.decoder).join();
    }
    return null;
  }

  static Future<String?> checkUserToken(String? name, String password) async {
    final String json = jsonEncode(<String, dynamic>{
      "password" : password,
    });
    HttpClientResponse response = await RestAPI.createHttpsRequest("/token/$name/", {}, 2, json);
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
    HttpClientResponse response = await RestAPI.createHttpsRequest("/login/", {}, 1, json);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return await response.transform(utf8.decoder).join();
    }
    return null;
  }

  static Future<bool> recover(String? name) async {
    HttpClientResponse response = await RestAPI.createHttpsRequest("/recover", {"username" : name}, 0, null);
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
    HttpClientResponse response = await RestAPI.createHttpsRequest("/signup/", {}, 1, json);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return await response.transform(utf8.decoder).join();
    }
    return null;
  }

  static Future<int?> getUserPoints() async {
    HttpClientResponse response = await RestAPI.createHttpsRequest("/api/users/${global.username}/points/", {}, 0, null);
    if (response.statusCode == 200) {
      return int.parse(await response.transform(utf8.decoder).join());
    }
    return null;
  }

  static Future<bool> changePassword(String username, String password) async {
    final String json = jsonEncode(<String, dynamic> {
      "password" : password
    });
    HttpClientResponse response = await RestAPI.createHttpsRequest("/api/users/$username/", {}, 2, json);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  static Future<bool> changeEmail(String username, String email) async {
    final String json = jsonEncode(<String, dynamic> {
      "email" : email
    });
    HttpClientResponse response = await RestAPI.createHttpsRequest("/api/users/$username/", {}, 2, json);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }
}