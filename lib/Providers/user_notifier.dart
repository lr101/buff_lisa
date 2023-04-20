import 'dart:typed_data';

import 'package:buff_lisa/Files/DTOClasses/user.dart';
import 'package:flutter/cupertino.dart';

import '../Files/DTOClasses/pin.dart';
import '../Files/Other/global.dart' as global;

class UserNotifier with ChangeNotifier {

  final List<User> _users = [];

  User getUser(String username) => _users.firstWhere((element) => element.username == username, orElse: () => _createUser(username));

  Future<void> updatePins(String username, List<Pin> pins) async {
    await getUser(username).updatePins(pins);
    notifyListeners();
  }

  Future<void> updateProfileImage(String username) async {
    await getUser(username).profileImage.refresh();
    await getUser(username).profileImageSmall.refresh();
    notifyListeners();
  }

  User _createUser(String username) {
    User user = User(username: username);
    _users.add(user);
    return user;
  }

  Future<void> removePin(String username, int id) async {
    await getUser(username).removePin(id);
    notifyListeners();
  }

  Future<void> addPin(String username,Pin pin) async {
    if (pin.username == global.localData.username) {
     await getUser(username).addPin(pin);
     notifyListeners();
    }
  }

  void clearPinsNotUser(String username) {
    _users.where((element) => element.username != username).forEach((element) {element.pins = null;});
    notifyListeners();
  }

  void removeUser(String username) {
    _users.removeWhere((element) => element.username == username);
    notifyListeners();
  }
}