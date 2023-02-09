import 'dart:convert';
import 'package:buff_lisa/Files/DTOClasses/ranking.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_groups.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_pins.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_users.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:buff_lisa/Files/AbstractClasses/async_type.dart';
import 'group.dart';
import 'pin.dart';
import 'package:hive/hive.dart';

part 'groupDTO.g.dart';

@HiveType(typeId: 1)
class GroupDTO extends HiveObject {

  /// Group Id of the group - identifies it uniquely
  @HiveField(0)
  final int groupId;

  /// name of the group shown to users to identify the group uniquely
  @HiveField(1)
  String name;

  /// visibility of a group
  /// 0 : public
  /// 1 : private
  /// 2 : TODO not yet implemented
  @HiveField(2)
  int visibility;

  /// String: invite url of a private group
  /// null: user is not a member or group is public
  @HiveField(3)
  String? inviteUrl;

  /// String: group admin of a group
  /// null: group admin not yet loaded from server or user is not a member of the private group
  @HiveField(4)
  String? groupAdmin;

  /// String: description of a group
  /// null: description is not yet loaded from server or user is not a member of the private group
  @HiveField(5)
  String? description;

  /// Uint8List: image profile picture byte data
  /// null: not yet loaded from server
  @HiveField(6)
  Uint8List? profileImage;

  /// Uint8List: image pin picture byte data
  /// null: not yet loaded from server
  @HiveField(7)
  Uint8List? pinImage;

  GroupDTO({
    required this.groupId,
    required this.name,
    required this.visibility,
    required this.inviteUrl,
    required this.groupAdmin,
    required this.description,
    required this.profileImage,
    required this.pinImage
  });

  GroupDTO.fromGroup(Group group):
      groupId = group.groupId,
      name = group.name,
      pinImage = group.pinImage.syncValue,
      profileImage = group.profileImage.syncValue,
      visibility = group.visibility,
      inviteUrl = group.inviteUrl,
      groupAdmin = group.groupAdmin.syncValue,
      description = group.description.syncValue;

  Group toGroup() {
    return Group(groupId: groupId, name: name, visibility: visibility, inviteUrl: inviteUrl, groupAdmin: groupAdmin, description: description, profileImage: profileImage,  pinImage: pinImage);
  }
}