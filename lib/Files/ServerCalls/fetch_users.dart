import 'dart:convert';

import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/DTOClasses/ranking.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/ServerCalls/restAPI.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
class FetchUsers {

  /// returns a list of members and the amount of points they have of a specific [group]
  /// throws an Exception if an error occurs
  /// GET Request to Server
  static Future<List<Ranking>> fetchGroupMembers(Group group) async {
    Response response = await RestAPI.createHttpsRequest("/api/groups/${group.groupId}/members" , {}, 0);
    if (response.statusCode == 200) {
      List<Ranking> members = [];
      List<dynamic> values = json.decode(response.body);
      for (dynamic d in values) {
        members.add(Ranking.fromJson(d));
      }
      return members;
    } else {
      throw Exception("Groups could not be loaded: ${response.statusCode} error code");
    }
  }

  /// returns the hashed password of an user identified by [name] of the server
  /// returns null if user does not exist
  /// GET Request to Server
  static Future<String?> checkUser(String? name) async {
    name ??= global.localData.username;
    Response response = await RestAPI.createHttpsRequest("/login/$name/", {}, 0, timeout: 3);
    if (response.statusCode == 200) {
      return response.body;
    }
    return null;
  }

  /// returns the token of an user identified by [name]
  /// returns null if the user does not exist
  /// GET Request to Server
  /// TODO delete if all users changed to new token auth
  static Future<String?> checkUserToken(String? name, String password) async {
    final String json = jsonEncode(<String, dynamic>{
      "password" : password,
    });
    Response response = await RestAPI.createHttpsRequest("/token/$name/", {}, 2,encode:  json, timeout: 3);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body;
    }
    return null;
  }

  /// returns the token of an user identified by [name]
  /// returns null if the user does not exist
  /// GET Request to Server
  static Future<String?> auth(String? name, String password) async {
    final String json = jsonEncode(<String, dynamic>{
      "password" : password,
      "username" : name,
    });
    try {
      Response response = await RestAPI.createHttpsRequest("/login/", {}, 1, encode: json, timeout: 3);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body;
      }
      return null;
    } catch(_,e) {
      if (kDebugMode) print(_);
    }
    return null;
  }

  /// returns the profile picture as a byte list of a username that is identified by [username]
  /// throws an Exception if an error occurs
  /// GET Request to Server
  static Future<Uint8List> fetchProfilePicture(String username) async {
    Response response = await RestAPI.createHttpsRequest("/api/users/$username/profile_picture", {}, 0);
    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        return response.bodyBytes;
      } else {
        return (await rootBundle.load("images/profile.jpg")).buffer.asUint8List();
      }
    } else {
      throw Exception("failed to load mona");
    }
  }

  /// returns the profile picture as a byte list of a username that is identified by [username]
  /// throws an Exception if an error occurs
  /// GET Request to Server
  static Future<Uint8List> fetchProfilePictureSmall(String username) async {
    Response response = await RestAPI.createHttpsRequest("/api/users/$username/profile_picture_small", {}, 0,);
    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        return response.bodyBytes;
      } else {
        throw Exception("failed to load mona");
      }
    } else {
      throw Exception("failed to load mona");
    }
  }

  /// This methods send a password recover request to the server
  /// returns true if email is successfully send
  /// returns false if a problem occurred at the server
  /// GET Request to Server
  static Future<bool> recover(String? name) async {
    Response response = await RestAPI.createHttpsRequest("/recover", {"username" : name}, 0, timeout: 3);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  }

  /// creates a new user account on the server
  /// returns the token of the new account
  /// returns null if the account creation was unsuccessful
  /// POST Request to Server
  static Future<String?> signupNewUser(String username, String hash, String email) async {
    final String json = jsonEncode(<String, dynamic>{
      "username" : username,
      "password" : hash,
      "email" : email
    });
    Response response = await RestAPI.createHttpsRequest("/signup/", {}, 1, encode: json, timeout: 3);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body;
    }
    return null;
  }

  /// changes the [password] of the user identified by [username]
  /// returns true if change was successful
  /// returns false if change was unsuccessful
  /// PUT Request to Server
  static Future<bool> changePassword(String username, String password) async {
    final String json = jsonEncode(<String, dynamic> {
      "password" : password
    });
    Response response = await RestAPI.createHttpsRequest("/api/users/$username/", {}, 2, encode: json);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  /// changes the [email] of the user identified by [username]
  /// returns true if change was successful
  /// returns false if change was unsuccessful
  /// PUT Request to Server
  static Future<bool> changeEmail(String username, String email) async {
    final String json = jsonEncode(<String, dynamic> {
      "email" : email
    });
    Response response = await RestAPI.createHttpsRequest("/api/users/$username/", {}, 2, encode: json);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  /// changes the [profilePicture] of the user identified by [username]
  /// returns true if change was successful
  /// returns false if change was unsuccessful
  /// PUT Request to Server
  static Future<Uint8List?> changeProfilePicture(String username, Uint8List profilePicture) async {
    final String json = jsonEncode(<String, dynamic> {
      "image" : profilePicture
    });
    Response response = await RestAPI.createHttpsRequest("/api/users/$username/profile_picture", {}, 2,encode:  json);
    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    return null;
  }

  static Future<bool> postReportUser(String reportedUsername, String reportMessage) async {
    final String json = jsonEncode(<String, dynamic>{
      "report" : reportedUsername,
      "username" : global.localData.username,
      "message" : reportMessage
    });
    final response = await RestAPI.createHttpsRequest("/api/report", {}, 1, encode: json);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  }

  static Future<bool> getDeleteCode() async {
    final response = await RestAPI.createHttpsRequest("/api/delete-code/${global.localData.username}", {}, 0);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  }

  static Future<bool> deleteAccount(String code) async {
    final String json = jsonEncode(<String, dynamic>{
      "code" : code
    });
    final response = await RestAPI.createHttpsRequest("/api/users/${global.localData.username}", {}, 3, encode: json);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  }
}