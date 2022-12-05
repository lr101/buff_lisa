import 'package:flutter/cupertino.dart';

/// ChangeNotifier saving changes and information of the [CameraPage] Widget
class CameraGroupNotifier with ChangeNotifier {

  /// index of the currently selected group
  int currentGroupIndex = 0;

  /// get method of [currentGroupIndex]
  int get getGroupIndex  => currentGroupIndex;

  /// set method of [currentGroupIndex]
  /// NOTIFIES CHANGES
  void setGroupIndex(int index) {
    currentGroupIndex = index;
    notifyListeners();
  }

}