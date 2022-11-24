import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:buff_lisa/Files/AbstractClasses/to_json.dart';
import 'package:buff_lisa/Files/DTOClasses/ranking.dart';
import 'package:buff_lisa/Files/fetch_groups.dart';
import 'package:buff_lisa/Files/fetch_pins.dart';
import 'package:buff_lisa/Files/fetch_users.dart';
import 'package:flutter/material.dart';

import 'pin.dart';

class Group {
  final int groupId;
  final String name;
  final int visibility;
  final String? inviteUrl;
  String? groupAdmin;
  String? description;     //
  Uint8List? profileImage; //
  Uint8List? pinImage;     //
  List<Ranking>? members;    //
  Set<Pin>? pins;          //
  bool active = false;


  Group({
    required this.groupId,
    required this.name,
    required this.groupAdmin,
    required this.visibility,
    required this.inviteUrl,
    this.description,
    this.profileImage,
    this.pinImage
  });

  Group.fromJson(Map<String, dynamic> json):
    groupId = json['groupId'],
    name = json['name'],
    groupAdmin = json['groupAdmin'],
    description = json['description'],
    profileImage = _getImageBinary(json['profileImage']),
    pinImage = _getImageBinary(json['pinImage']),
    visibility = json['visibility'],
    members = _getRankingList(json['members']),
    inviteUrl = json['inviteUrl'];

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

  static List<Ranking>? _getRankingList(json) {
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

  static Uint8List? _getImageBinary(String? dynamicList) {
    if (dynamicList != null) {
      return base64Decode(dynamicList);
    } else {
      return null;
    }

  }

  Future<Uint8List> getProfileImage() async {
    if (profileImage != null) {
      return profileImage!;
    } else {
      profileImage = await FetchGroups.getProfileImage(this);
      return profileImage!;
    }
  }
  Widget getProfileImageWidget() {
    return FutureBuilder<Uint8List>(
      future: getProfileImage(),
      builder: (context, snapshot) => snapshot.hasData ? Image.memory(snapshot.data!) : const CircularProgressIndicator(),
    );
  }

  Future<Uint8List> getPinImage() async {
    if (pinImage != null) {
      return pinImage!;
    } else {
      pinImage = await FetchGroups.getPinImage(this);
      return pinImage!;
    }
  }
  Widget getPinImageWidget() {
    return FutureBuilder<Uint8List>(
      future: getPinImage(),
      builder: (context, snapshot) => snapshot.hasData ? Image.memory(snapshot.data!) : const CircularProgressIndicator(),
    );
  }

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

  Future<String> getDescription() async {
    if (description != null) {
      return description!;
    } else {
      description = await FetchGroups.getGroupDescription(groupId);
      return description!;
    }
  }
  Widget getDescriptionWidget() {
    return FutureBuilder<String>(
      future: getDescription(),
      builder: (context, snapshot) => snapshot.hasData ? Text(snapshot.requireData) : const Text("LOADING..."),
    );
  }

  Future<String> getAdmin() async {
    if (groupAdmin != null) {
      return groupAdmin!;
    } else {
      groupAdmin = await FetchGroups.getGroupAdmin(groupId);
      return groupAdmin!;
    }
  }
  Widget getAdminWidget() {
    return FutureBuilder<String>(
      future: getAdmin(),
      builder: (context, snapshot) => snapshot.hasData ? Text(snapshot.requireData) : const Text("LOADING..."),
    );
  }

  Future<Set<Pin>> getPins() async {
    if (pins != null) {
      return pins!;
    } {
      pins = await FetchPins.fetchGroupPins(this);
      return pins!;
    }
  }

  Set<Pin> getSyncPins() {
    if (pins != null) {
      return pins!;
    } else {
      return {};
    }
  }

  void removePin(Pin pin) {
    if (pins != null) {
      pins!.remove(pin);
    }
  }



}