import 'package:flutter/cupertino.dart';

import '../Files/DTOClasses/pin.dart';
import '../Files/DTOClasses/user.dart';
import '../Files/Other/global.dart' as global;

class UserNotifier with ChangeNotifier {

  final List<User> _users = [];

  User getUser(String username) => _users.firstWhere((element) => element.username == username, orElse: () => _createUser(username));

  User _createUser(String username) {
    User user = User(username: username);
    _users.add(user);
    return user;
  }
}