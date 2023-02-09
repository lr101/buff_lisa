import 'package:buff_lisa/Files/ServerCalls/fetch_pins.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/DTOClasses/hive_handler.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:buff_lisa/Files/DTOClasses/user.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;

class HiddenPinPageNotifier with ChangeNotifier {

  final Set<Pin> _pins = {};

  Set<Pin> get pins => _pins;

  Future<void> loadOffline(List<Group> groups) async{
    HiveHandler<int, DateTime> hiddenPosts = await HiveHandler.fromInit<int, DateTime>(global.hiddenPosts);
    for (int id in await hiddenPosts.keys()) {
      _pins.add(await FetchPins.fetchUserPin(id, groups));
    }
    notifyListeners();
  }

  Future<void> unHidePin(Pin pin) async{
    _pins.remove(pin);
    HiveHandler<int, DateTime> hiddenPosts = await HiveHandler.fromInit<int, DateTime>(global.hiddenPosts);
    await hiddenPosts.deleteByKey(pin.id);
    notifyListeners();
  }

}