import 'package:flutter/cupertino.dart';

class LoadingNotifier with ChangeNotifier {

  bool _loaded = false;

  void isLoaded() {
    _loaded = true;
    notifyListeners();
  }

  bool get getStatus => _loaded;

}