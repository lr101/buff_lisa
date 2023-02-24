import 'package:flutter/cupertino.dart';

/// ChangeNotifier saving changes and information of the [CameraPage] Widget
class ProfileNotifier with ChangeNotifier {

  Map<int, Widget?> pins = {};

  void addPin(Widget widget, int id) {
    pins[id] = widget;
    notifyListeners();
  }

  List<Widget> get widgets => pins.values.map((e) => e ?? Container()).toList();

  void addPinId(int id) {
    pins[id] = null;
    notifyListeners();
  }

}