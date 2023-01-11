import 'package:buff_lisa/Files/ServerCalls/fetch_pins.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_users.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../Files/DTOClasses/group.dart';
import '../Files/DTOClasses/hive_handler.dart';
import '../Files/DTOClasses/user.dart';
import '../Files/DTOClasses/user.dart';
import '../Files/Other/global.dart' as global;

class HiddenUserPageNotifier with ChangeNotifier {

  Set<User> _users = {};

  Set<User> get users => _users;

  void setUsers (Set<User> users) {
    _users = users;
    notifyListeners();
  }

  Future<void> unHideUser(User user) async{
    _users.remove(user);
    HiveHandler<String, DateTime> hiddenPosts = await HiveHandler.fromInit<String, DateTime>(global.hiddenUsers);
    await hiddenPosts.deleteByKey(user.username);
    notifyListeners();
  }

}