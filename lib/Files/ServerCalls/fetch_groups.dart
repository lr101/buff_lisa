import 'dart:convert';
import 'dart:typed_data';
import 'dart:convert' show utf8;
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/ServerCalls/restAPI.dart';
import 'package:http/http.dart';

class FetchGroups {

  /// returns the list of groups the current user is a member of
  /// GET request to server
  /// throws an Exception when an error occurs during server call
  static Future<List<Group>> getUserGroups() async {
    Response response = await RestAPI.createHttpsRequest("/api/users/${global.localData.username}/groups" , {}, 0, timeout: 20);
    if (response.statusCode == 200) {
      await global.localData.groupRepo.clear();
      return _toGroupList(response);
    } else {
      throw Exception("Groups could not be loaded: ${response.statusCode} error code");
    }
  }

  /// returns a the group corresponding the [groupId]
  /// GET request to server
  /// throws an Exception when an error occurs during server call
  static Future<Group> getGroup(int groupId, [saveOffline = true]) async {
    Response response = await RestAPI.createHttpsRequest("/api/groups/$groupId" , {}, 0);
    if (response.statusCode == 200) {
      return Group.fromJson(jsonDecode( response.body) as Map<String, dynamic>, saveOffline);
    } else {
      throw Exception("Groups could not be loaded: ${response.statusCode} error code");
    }
  }

  /// returns a list of group corresponding to the list of [groupIds]
  /// GET request to server
  /// throws an Exception when an error occurs during server call
  static Future<List<Group>> getGroups(List<int> groupIds) async {
    String ids = "";
    if (groupIds.isNotEmpty) ids += groupIds[0].toString();
    for (int i = 1; i < groupIds.length; i ++) { ids+="-"; ids += groupIds[i].toString();}
    if (ids == "") return [];
    Response response = await RestAPI.createHttpsRequest("/api/groups" , {"ids" : ids}, 0);
    if (response.statusCode == 200) {
      return _toGroupList(response, false);
    } else {
      throw Exception("Groups could not be loaded: ${response.statusCode} error code");
    }
  }

  /// returns a list of group Ids of groups where:
  /// - the user is not a member of
  /// - the search value matches the search pattern on the server
  /// GET request to server
  /// throws an Exception when an error occurs during server call
  static Future<List<int>> fetchAllGroupsWithoutUserGroupsIds(String? value) async {
    Map<String, dynamic> params = {};
    params["withUser"] = "false";
    if (value != null) params["search"] = value;
    Response response = await RestAPI.createHttpsRequest("/api/groupIds" , params, 0);
    if (response.statusCode == 200) {
      String res =  ( response.body);
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

  /// returns the group that is created on the server with [name], [description], [image], [visibility]
  /// POST request to server
  /// returns null if an Error occurred during server call TODO exception?
  static Future<Group?> postGroup(String name, String description, Uint8List image, int visibility) async {
    final String json = jsonEncode(<String, dynamic> {
      "name" : name,
      "groupAdmin": global.localData.username,
      "description" : description,
      "profileImage": image,
      "visibility" : visibility
    });
    final response =  await RestAPI.createHttpsRequest("/api/groups", {}, 1,encode:  json);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Group.fromJson(jsonDecode( response.body) as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  /// returns the group that is updating on the server with [name], [description], [image], [visibility]
  /// PUT request to server
  /// returns null if an Error occurred during server call TODO exception?
  static Future<Group?> putGroup(int groupId, String? name, String? description, Uint8List? image, double? visibility, String? groupAdmin) async {
    Map<String, dynamic> map =  {};
    if (name != null) map["name"] = name;
    if (description != null) map["description"] = description;
    if (image != null) map["profileImage"] = image;
    if (visibility != null) map["visibility"] = visibility.toInt();
    if (groupAdmin != null) map["groupAdmin"] = groupAdmin;
    final String json = jsonEncode(map);
    final response =  await RestAPI.createHttpsRequest("/api/groups/$groupId", {}, 2, encode: json);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Group.fromJson(jsonDecode( response.body) as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  /// returns the group of the group identified by [groupId] the current user tries to join
  /// POST request to server
  /// throws an Exception when an error occurs during server call
  static Future<Group> joinGroup(int groupId, String? inviteUrl) async {
    final String json = jsonEncode(<String, dynamic> {
      "username" : global.localData.username,
      "inviteUrl" : inviteUrl
    });
    Response response = await RestAPI.createHttpsRequest("/api/groups/$groupId/members", {}, 1,  encode: json);
    if (response.statusCode == 200) {
      return Group.fromJson(jsonDecode( response.body) as Map<String, dynamic>);
    } else {
      throw Exception("Group could not be joined: ${response.statusCode} error code");
    }
  }

  /// returns true if the user successfully left the group identified by [groupId]
  /// returns false if an error occurred
  /// DELETE request to server
  static Future<bool> leaveGroup(int groupId) async {
    Response response = await RestAPI.createHttpsRequest("/api/groups/$groupId/members", {}, 3);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  /// returns the description of a group identified by [groupId]
  /// throws an Exception if an error occurs
  /// GET Request to Server
  static Future<String?> getGroupDescription(int groupId) async {
    Response response = await RestAPI.createHttpsRequest("/api/groups/$groupId/description", {}, 0);
    if (response.statusCode == 200) {
      try {
        return utf8.decode(response.bodyBytes);
      } catch(_) {
        return null;
      }
    } else {
      throw Exception("Group is private or does not exist");
    }
  }

  /// returns the username of the group admin of a group identified by [groupId]
  /// throws an Exception if an error occurs
  /// GET Request to Server
  static Future<String> getGroupAdmin(int groupId) async {
    Response response = await RestAPI.createHttpsRequest("/api/groups/$groupId/admin", {}, 0);
    if (response.statusCode == 200) {
      return  response.body;
    } else {
      throw Exception("Group is private or does not exist");
    }
  }

  /// returns the invite url of a private group identified by [groupId]
  /// throws an Exception if an error occurs
  /// GET Request to Server
  static Future<String> getInviteUrl(int groupId) async {
    Response response = await RestAPI.createHttpsRequest("/api/groups/$groupId/invite_url", {}, 0);
    if (response.statusCode == 200) {
      return  response.body;
    } else {
      throw Exception("Group is private or does not exist");
    }
  }

  /// returns the profile image as byte list of a group identified by [groupId]
  /// throws an Exception if an error occurs
  /// GET Request to Server
  static Future<Uint8List> getProfileImage(Group group) async {
    Response response = await RestAPI.createHttpsRequest("/api/groups/${group.groupId}/profile_image", {}, 0);
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception("failed to load profile image");
    }
  }

  /// returns the pin image as byte list of a group identified by [groupId]
  /// throws an Exception if an error occurs
  /// GET Request to Server
  static Future<Uint8List> getPinImage(Group group) async {
    Response response = await RestAPI.createHttpsRequest("/api/groups/${group.groupId}/pin_image", {}, 0);
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception("failed to load pin image");
    }
  }




  //---------------------------------------------------------


  /// returns a list of groups by converting the body of a http response to Group objects
  static Future<List<Group>> _toGroupList(Response response, [saveOffline = true]) async {
    List<dynamic> values = json.decode( response.body);
    List<Group> groups = [];
    for (var element in values) {
      groups.add(Group.fromJson(element, saveOffline));
    }
    return groups;
  }
}