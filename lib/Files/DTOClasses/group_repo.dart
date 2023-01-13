import 'dart:io';

import 'package:buff_lisa/Files/DTOClasses/groupDTO.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'group.dart';

class GroupRepo {
  late Box<GroupDTO> box;

  Future<void> init(String boxName) async {
    box = await Hive.openBox<GroupDTO>(boxName);
  }

  void setGroup(Group group) {
    GroupDTO groupDTO = GroupDTO.fromGroup(group);
    box.put(groupDTO.groupId, groupDTO);
  }

  Group? getGroup(int id) {
    GroupDTO? groupDTO = box.get(id);
    if (groupDTO != null) {
      return groupDTO.toGroup();
    }
    return null;
  }

  Future<void> clear() async{
    await box.clear();
  }

  List<Group> getGroups() {
    List<GroupDTO> list = box.values.toList();
    return list.map((e) => e.toGroup()).toList();
  }

  void deleteGroup (int id) => box.delete(id);
}