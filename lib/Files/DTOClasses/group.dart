import 'dart:convert';
import 'dart:typed_data';
import 'package:buff_lisa/Files/DTOClasses/ranking.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_groups.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_pins.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_users.dart';
import 'package:flutter/material.dart';

import 'pin.dart';

class Group {

  /// Group Id of the group - identifies it uniquely
  final int groupId;

  /// name of the group shown to users to identify the group uniquely
  String name;

  /// visibility of a group
  /// 0 : public
  /// 1 : private
  /// 2 : TODO not yet implemented
  int visibility;

  /// String: invite url of a private group
  /// null: user is not a member or group is public
  String? inviteUrl;

  /// String: group admin of a group
  /// null: group admin not yet loaded from server or user is not a member of the private group
  String? groupAdmin;

  /// String: description of a group
  /// null: description is not yet loaded from server or user is not a member of the private group
  String? description;

  /// Uint8List: image profile picture byte data
  /// null: not yet loaded from server
  Uint8List? profileImage;

  /// Uint8List: image pin picture byte data
  /// null: not yet loaded from server
  Uint8List? pinImage;

  /// List<Ranking>: members of a group
  /// null: not yet loaded from server or user is not a member of the private group
  List<Ranking>? members;

  /// List<Pin>: pins of a group
  /// null: null: not yet loaded from server or user is not a member of the private group
  Set<Pin>? pins;

  /// param for tracking if group pins are currently displayed on the map = active
  /// false: group pins are not being displayed = default behavior
  /// true: group pins are being displayed
  bool active = false;

  /// Constructor of group
  Group({
    required this.groupId,
    required this.name,
    required this.visibility,
    required this.inviteUrl,
    this.groupAdmin,
    this.description,
    this.profileImage,
    this.pinImage
  });

  /// Constructor of group when data is in json format
  Group.fromJson(Map<String, dynamic> json):
    groupId = json['groupId'],
    name = json['name'],
    groupAdmin = json['groupAdmin'],
    description = json['description'],
    profileImage = _getImageBinary(json['profileImage']),
    pinImage = _getImageBinary(json['pinImage']),
    visibility = json['visibility'],
    members = _getMemberList(json['members']),
    inviteUrl = json['inviteUrl'];

  /// Formats group data to json
  Future<Map<String, dynamic>> toJson() async {
    return {
      "groupId": groupId,
      "profileImage": profileImage,
      "name" : name,
      "groupAdmin" : groupAdmin,
      "description" : description,
      "visibility" : visibility,
      "inviteUrl" : inviteUrl
    };
  }

  /// returns the members from json
  static List<Ranking>? _getMemberList(json) {
    if (json != null) {
      List<Ranking> rankings = [];
      for (Map<String, dynamic> entry in json) {
        rankings.add(Ranking.fromJson(entry));
      }
      return rankings;
    } else {
      return null;
    }
  }

  /// returns the image binary from base64 encoded data
  static Uint8List? _getImageBinary(String? dynamicList) {
    if (dynamicList != null) {
      return base64Decode(dynamicList);
    } else {
      return null;
    }

  }

  /// returns the profile image byte data from local if existing or server
  Future<Uint8List> getProfileImage() async {
    if (profileImage != null) {
      return profileImage!;
    } else {
      profileImage = await FetchGroups.getProfileImage(this);
      return profileImage!;
    }
  }

  /// returns the profile image as Image Widget from local if existing or server
  Widget getProfileImageWidget() {
    return FutureBuilder<Uint8List>(
      future: getProfileImage(),
      builder: (context, snapshot) => snapshot.hasData ? Image.memory(snapshot.data!) : const CircularProgressIndicator(),
    );
  }

  /// returns the pin image byte data from local if existing or server
  Future<Uint8List> getPinImage() async {
    if (pinImage != null) {
      return pinImage!;
    } else {
      pinImage = await FetchGroups.getPinImage(this);
      return pinImage!;
    }
  }

  /// returns the pin image as Image Widget from local if existing or server
  Widget getPinImageWidget() {
    return FutureBuilder<Uint8List>(
      future: getPinImage(),
      builder: (context, snapshot) => snapshot.hasData ? Image.memory(snapshot.data!) : const CircularProgressIndicator(),
    );
  }

  /// returns a list of all member from local if existing or server
  /// last index of member list when loading from server is the admin user
  Future<List<Ranking>> getMembers() async {
    if (members != null) {
      return members!;
    } else {
      List<Ranking> ranking = await FetchUsers.fetchGroupMembers(this);
      groupAdmin = ranking.last.username;
      ranking.removeAt(ranking.length - 1);
      members = ranking;
      return members!;
    }
  }

  /// returns the description of a group as String form local if existing or from server
  Future<String> getDescription() async {
    if (description != null) {
      return description!;
    } else {
      description = await FetchGroups.getGroupDescription(groupId);
      return description!;
    }
  }

  /// returns the description of a group as String form local if existing or from server
  Future<String> getInviteUrl() async {
    if (inviteUrl != null) {
      return inviteUrl!;
    } else {
      inviteUrl = await FetchGroups.getInviteUrl(groupId);
      return inviteUrl!;
    }
  }

  /// returns the description as Text Widget of a group form local if existing or from server
  Widget getDescriptionWidget() {
    return FutureBuilder<String>(
      future: getDescription(),
      builder: (context, snapshot) => snapshot.hasData ? Text(snapshot.requireData) : const Text("LOADING..."),
    );
  }

  /// returns the admin of a group as String form local if existing or from server
  Future<String> getAdmin() async {
    if (groupAdmin != null) {
      return groupAdmin!;
    } else {
      groupAdmin = await FetchGroups.getGroupAdmin(groupId);
      return groupAdmin!;
    }
  }

  /// returns the admin of a group as Text Widget form local if existing or from server
  Widget getAdminWidget() {
    return FutureBuilder<String>(
      future: getAdmin(),
      builder: (context, snapshot) => snapshot.hasData ? Text(snapshot.requireData) : const Text("LOADING..."),
    );
  }

  /// returns the pin set of a group form local if existing or from server
  Future<Set<Pin>> getPins() async {
    if (pins != null) {
      return pins!;
    } {
      pins = await FetchPins.fetchGroupPins(this);
      return pins!;
    }
  }

  /// adds a pin to the set of pins of a group
  /// if the pins are not loaded from the server, the pin will already be online and does not to be added
  /// if the pins are already loaded from the server, the pin is added to the set
  /// returns a flag for if adding was successful
  /// true: adding was successful
  /// false: pin is already existing
  /// TODO can also not load the pins if not fetched from server yet
  Future<bool> setPin(Pin pin) async {
    if (pins != null) {
      if (!pins!.any((element) => element.id == pin.id)) {
        pins!.add(pin);
        return true;
      } else {
        return false;
      }
    } else {
      pins = await FetchPins.fetchGroupPins(this);
      return false;
    }
  }

  /// returns the pin set of a group synchronised
  /// if existing the existing set is returned
  /// if not existing an empty set is returned
  Set<Pin> getSyncPins() {
    if (pins != null) {
      return pins!;
    } else {
      return {};
    }
  }

  /// removes a pin form the pins set
  void removePin(Pin pin) {
    if (pins != null) {
      pins!.remove(pin);
    }
  }



}