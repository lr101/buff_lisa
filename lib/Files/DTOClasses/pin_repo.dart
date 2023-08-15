import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:buff_lisa/Files/DTOClasses/pinDTO.dart';
import 'package:hive/hive.dart';

import 'group.dart';

class PinRepo {

  late Box<PinDTO> box;

  Future<void> init(String boxName) async {
    box = await Hive.openBox<PinDTO>(boxName);
  }

  static Future<PinRepo> fromInit(String boxName) async {
    PinRepo pinRepo = PinRepo();
    await pinRepo.init(boxName);
    return pinRepo;
  }

  void setPin(Pin pin) {
    PinDTO pinDTO = PinDTO.fromPin(pin);
    box.put(pin.id.toString(),pinDTO);
  }

  Pin? getPin(int id, Group group) {
    PinDTO? pinDTO = box.get(id.toString());
    if (pinDTO != null) {
      return pinDTO.toPin(group);
    }
    return null;
  }

  Set<Pin> getPins(List<Group> groups) {
    List<PinDTO> list = box.values.toList();
    Set<Pin> pins = {};
    for (PinDTO pinDTO in list) {
      for (Group group in groups) {
        if (group.groupId == pinDTO.groupId) {
          pins.add(pinDTO.toPin(group)!);
          break;
        }
      }
    }
    return pins;
  }

  void deletePin (int id) => box.delete(id.toString());

  Future<void> clear() async => await box.clear();
}