import 'package:flutter/cupertino.dart';

/// ChangeNotifier saving changes and information of the [CameraPage] Widget
class CameraGroupNotifier with ChangeNotifier {
  int currentGroupIndex = 0;

  int get getGroupIndex  => currentGroupIndex;

  void setGroupIndex(int index) {
    currentGroupIndex = index;
    notifyListeners();
  }

}