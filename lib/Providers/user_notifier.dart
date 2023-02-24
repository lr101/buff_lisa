import 'package:buff_lisa/Files/DTOClasses/user.dart';
import 'package:flutter/cupertino.dart';

class UserNotifier with ChangeNotifier {

  final List<User> _users = [];

  User getUser(String username) => _users.firstWhere((element) => element.username == username, orElse: () => _createUser(username));

  User _createUser(String username) {
    User user = User(username: username);
    _users.add(user);
    return user;
  }

  void removeUser(String username) {
    _users.removeWhere((element) => element.username == username);
  }
}