import 'package:flutter/cupertino.dart';

import '../Files/DTOClasses/pin.dart';
import '../Files/Other/global.dart' as global;

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