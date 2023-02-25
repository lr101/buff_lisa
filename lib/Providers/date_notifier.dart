import 'package:buff_lisa/Files/DTOClasses/user.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:flutter/cupertino.dart';

class DateNotifier with ChangeNotifier {

  DateTime? getDate() {
    return global.localData.getLastSeen();
  }

  void setDateNow() {
    global.localData.setLastSeenNow();
    notifyListeners();
  }

  void notifyReload() {
    notifyListeners();
  }

}