import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:buff_lisa/Files/restAPI.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'global.dart' as global;
class FetchGroups {

  static Future<List<Group>> getUserGroups() async {
    HttpClientResponse response = await RestAPI.createHttpsRequest("/api/users/${global.username}/groups" , {}, 0, null);
    if (response.statusCode == 200) {
      return _toGroupList(response);
    } else {
      throw Exception("Groups could not be loaded: ${response.statusCode} error code");
    }
  }

  static Future<Group> getGroup(int groupId) async {
    HttpClientResponse response = await RestAPI.createHttpsRequest("/api/groups/$groupId" , {}, 0, null);
    if (response.statusCode == 200) {
      return Group.fromJson(jsonDecode(await response.transform(utf8.decoder).join()) as Map<String, dynamic>);
    } else {
      throw Exception("Groups could not be loaded: ${response.statusCode} error code");
    }
  }

  static Future<List<Group>> getGroups(List<int> groupIds) async {
    String ids = "";
    if (groupIds.isNotEmpty) ids += groupIds[0].toString();
    for (int i = 1; i < groupIds.length; i ++) { ids+="-"; ids += groupIds[i].toString();}
    if (ids == "") return [];
    HttpClientResponse response = await RestAPI.createHttpsRequest("/api/groups" , {"ids" : ids}, 0, null);
    if (response.statusCode == 200) {
      return _toGroupList(response);
    } else {
      throw Exception("Groups could not be loaded: ${response.statusCode} error code");
    }
  }

  static Future<List<int>> fetchAllGroupsWithoutUserGroupsIds(String? value) async {
    Map<String, dynamic> params = {};
    params["withUser"] = "false";
    if (value != null) params["search"] = value;
    HttpClientResponse response = await RestAPI.createHttpsRequest("/api/groupIds" , params, 0, null);
    if (response.statusCode == 200) {
      String res =  (await response.transform(utf8.decoder).join());
      if (!res.contains("[]")) {
        return res.replaceAll('[', '').replaceAll(']', '')
        .split(',')
        .map<int>((e) => int.parse(e)).toList();
      } else {
        return [];
      }
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
    final response =  await RestAPI.createHttpsRequest("/api/groups", {}, 1, json);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Group.fromJson(jsonDecode(await response.transform(utf8.decoder).join()) as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  static Future<Group> joinGroup(int groupId, String? inviteUrl) async {
    final String json = jsonEncode(<String, dynamic> {
      "username" : global.username,
      "inviteUrl" : inviteUrl
    });
    HttpClientResponse response = await RestAPI.createHttpsRequest("/api/groups/$groupId/members", {}, 1, json);
    if (response.statusCode == 200) {
      return Group.fromJson(jsonDecode(await response.transform(utf8.decoder).join()) as Map<String, dynamic>);
    } else {
      throw Exception("Group could not be joined: ${response.statusCode} error code");
    }
  }

  static Future<bool> leaveGroup(int groupId) async {
    HttpClientResponse response = await RestAPI.createHttpsRequest("/api/groups/$groupId/members", {}, 3, null);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future<String> getGroupDescription(int groupId) async {
    HttpClientResponse response = await RestAPI.createHttpsRequest("/api/groups/$groupId/description", {}, 0, null);
    if (response.statusCode == 200) {
      return await response.transform(utf8.decoder).join();
    } else {
      throw Exception("Group is private or does not exist");
    }
  }

  static Future<String> getGroupAdmin(int groupId) async {
    HttpClientResponse response = await RestAPI.createHttpsRequest("/api/groups/$groupId/admin", {}, 0, null);
    if (response.statusCode == 200) {
      return await response.transform(utf8.decoder).join();
    } else {
      throw Exception("Group is private or does not exist");
    }
  }

  static Future<Uint8List> getProfileImage(Group group) async {
    HttpClientResponse response = await RestAPI.createHttpsRequest("/api/groups/${group.groupId}/profile_image", {}, 0, null);
    if (response.statusCode == 200) {
      //TODO
      return await ByteStream(response.cast()).toBytes();
    } else {
      throw Exception("failed to load mona");
    }
  }

  static Future<Uint8List> getPinImage(Group group) async {
    HttpClientResponse response = await RestAPI.createHttpsRequest("/api/groups/${group.groupId}/pin_image", {}, 0, null);
    if (response.statusCode == 200) {
      return await ByteStream(response.cast()).toBytes();
    } else {
      throw Exception("failed to load mona");
    }
  }




  //---------------------------------------------------------


  static Future<List<Group>> _toGroupList(HttpClientResponse response) async {
    List<dynamic> values = json.decode(await response.transform(utf8.decoder).join());

    List<Group> groups = [];
    for (var element in values) {
      groups.add(Group.fromJson(element));
    }
    return groups;
  }
}