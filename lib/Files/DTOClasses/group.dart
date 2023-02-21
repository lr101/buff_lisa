import 'dart:convert';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/DTOClasses/group_repo.dart';
import 'package:buff_lisa/Files/DTOClasses/ranking.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_groups.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_pins.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_users.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:buff_lisa/Files/AbstractClasses/async_type.dart';
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
  late final AsyncType<String> groupAdmin;

  /// String: description of a group
  /// null: description is not yet loaded from server or user is not a member of the private group
  late final AsyncType<String> description;

  /// Uint8List: image profile picture byte data
  /// null: not yet loaded from server
  late final AsyncType<Uint8List> profileImage;

  /// Uint8List: image pin picture byte data
  /// null: not yet loaded from server
  late final AsyncType<Uint8List> pinImage;

  /// List<Ranking>: members of a group
  /// null: not yet loaded from server or user is not a member of the private group
  late final AsyncType<List<Ranking>> members;

  /// List<Pin>: pins of a group
  /// null: null: not yet loaded from server or user is not a member of the private group
  late final AsyncType<Set<Pin>> pins;

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
    members,
    groupAdmin,
    description,
    pins,
    profileImage,
    pinImage,
    saveOffline = true
  }) {
    this.groupAdmin = AsyncType(value: groupAdmin, callback: () => FetchGroups.getGroupAdmin(groupId), callbackDefault: () async => "---", builder: (_) => Text(_));
    this.members = AsyncType(value: members, callback: _getMembers, callbackDefault: () async => []);
    this.description = AsyncType(value: description, callback: () => FetchGroups.getGroupDescription(groupId), callbackDefault: () async => "cannot be loaded", builder: (_) => Text(_));
    this.pins = AsyncType(value: pins, callback: _getPinsCallback, callbackDefault: () async => <Pin>{});
    this.profileImage = AsyncType<Uint8List>(value: profileImage,callback: () => FetchGroups.getProfileImage(this), callbackDefault: _defaultProfileImage, builder: (_) => Image.memory(_), save: (saveOffline) ? _saveOffline : null);
    this.pinImage = AsyncType<Uint8List>(value: pinImage,callback: () => FetchGroups.getPinImage(this), callbackDefault: _defaultPinImage, builder: (image) => Image.memory(image), save: (saveOffline) ? _saveOffline : null, retry: false);
  }

  /// Constructor of group when data is in json format
  static Group fromJson(Map<String, dynamic> json, [bool saveOffline = true]) {
    return Group(
        groupId: json['groupId'],
        name:  json['name'],
        visibility: json['visibility'],
        inviteUrl: json['inviteUrl'],
        description: json['description'],
        groupAdmin:  json['groupAdmin'],
        members: _getMemberList(json['members']),
        pinImage: _getImageBinary(json['pinImage']),
        profileImage: _getImageBinary(json['profileImage']),
        saveOffline: saveOffline
    );
  }

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

  Future<Uint8List> _defaultProfileImage () async => (await rootBundle.load('images/profile.jpg')).buffer.asUint8List();

  Future<Uint8List> _defaultPinImage () async => (await rootBundle.load('images/pin_border.png')).buffer.asUint8List();

  /// returns a list of all member from local if existing or server
  /// last index of member list when loading from server is the admin user
  Future<List<Ranking>> _getMembers() async {
      List<Ranking> ranking = await FetchUsers.fetchGroupMembers(this);
      groupAdmin.setValue(ranking.last.username);
      ranking.removeAt(ranking.length - 1);
      return ranking;
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

  /// returns the pin set of a group form local if existing or from server
  Future<Set<Pin>> _getPinsCallback() async {
      Set<Pin> pins = await FetchPins.fetchGroupPins(this);
      await _filter(pins);
      return pins;
  }

  int getNewOfflinePinId() {
    int min = 0;
    if (!pins.isEmpty) {
      for (Pin p in pins.syncValue ?? {}) {
        if (p.id < min) min = p.id;
      }
    }
    return min - 1;
  }

  /// adds a pin to the set of pins of a group
  /// if the pins are not loaded from the server, the pin will already be online and does not to be added
  /// if the pins are already loaded from the server, the pin is added to the set
  /// returns a flag for if adding was successful
  /// true: adding was successful
  /// false: pin is already existing
  /// TODO can also not load the pins if not fetched from server yet
  Future<bool> setPin(Pin pin) async {
    if (!pins.isEmpty) {
      if (!pins.syncValue!.any((element) => element.id == pin.id) && (await _filter({pin})).isNotEmpty) {
        pins.syncValue!.add(pin);
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  /// removes a pin form the pins set
  void removePin(Pin pin) {
    if (!pins.isEmpty) {
      pins.syncValue!.remove(pin);
    }
  }

  Future<void> _saveOffline() async {
    global.localData.repo.setGroup(this);
  }

  Future<Set<Pin>> _filter(Set<Pin> pins) async{
    Set<Pin> removesPins = {};
    List<String> usernames = await global.localData.hiddenUsers.keys();
    List<int> posts = await global.localData.hiddenPosts.keys();
    List<Pin> iterator = List.from(pins);
    for (Pin pin in iterator) {
      if (posts.any((element) => element == pin.id) || usernames.any((element) => element == pin.username)) {
        pins.remove(pin);
        removesPins.add(pin);
      }
    }
    return pins;
  }

  Future<Set<Pin>> filter() async{
    Set<Pin>? pinList = pins.syncValue;
    Set<Pin> filtered = {};
    if (pinList != null) {
      filtered = await _filter(pinList);
      pins.setValue(filtered);
    }
    return filtered;
  }



}