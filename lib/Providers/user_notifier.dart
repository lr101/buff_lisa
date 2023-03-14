import 'package:buff_lisa/Files/DTOClasses/user.dart';
import 'package:flutter/cupertino.dart';

import '../Files/DTOClasses/pin.dart';
import '../Files/Other/global.dart' as global;

class UserNotifier with ChangeNotifier {

  final List<User> _users = [];

  User getUser(String username) => _users.firstWhere((element) => element.username == username, orElse: () => _createUser(username));

  User _createUser(String username) {
    User user = User(username: username);
    _users.add(user);
    return user;
  }

  void removePin(String username, int id) {
    List<Pin>? pins = getUser(username).pins;
    if (pins != null) {
      pins.removeWhere((element) => element.id == id);
      notifyListeners();
    }
  }

  void addPin(String username,Pin pin) {
    if (pin.username == global.localData.username) {
      List<Pin>? pins = getUser(username).pins;
      if (pins != null) {
        pins.add(pin);
        notifyListeners();
      }
    }
  }

  void clearPinsNotUser(String username) {
    _users.where((element) => element.username != username).forEach((element) {element.pins = null;});
    notifyListeners();
  }

  void removeUser(String username) {
    _users.removeWhere((element) => element.username == username);
  }
}