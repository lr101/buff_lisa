import 'package:buff_lisa/Files/DTOClasses/groupDTO.dart';
import 'package:buff_lisa/Files/Other/local_data.dart';
import 'package:hive/hive.dart';

import '../Other/global.dart' as global;
import 'group.dart';

class GroupRepo {
  late Box<GroupDTO> box;

  Future<void> init(String boxName) async {
    box = await Hive.openBox<GroupDTO>(boxName);
  }

  static Future<GroupRepo> fromInit(String boxName) async {
    GroupRepo groupRepo = GroupRepo();
    await groupRepo.init(boxName);
    return groupRepo;
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

  Future<void> clear() async {
    await box.clear();
  }

  List<Group> getGroups() {
    List<GroupDTO> list = box.values.toList();
    return list.map((e) => e.toGroup()).toList();
  }

  void deleteGroup(int id) {
    box.delete(id);
    global.localData.setCamera(CameraOfflineValues.groupScroll, 0);
  }
}