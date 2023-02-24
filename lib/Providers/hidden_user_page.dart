import 'package:buff_lisa/Files/DTOClasses/user.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:flutter/cupertino.dart';

class HiddenUserPageNotifier with ChangeNotifier {

  Set<User> _users = {};

  Set<User> get users => _users;

  void setUsers (Set<User> users) {
    _users = users;
    notifyListeners();
  }

  Future<void> unHideUser(User user) async{
    _users.remove(user);
    await global.localData.hiddenUsers.deleteByKey(user.username);
    notifyListeners();
  }

}