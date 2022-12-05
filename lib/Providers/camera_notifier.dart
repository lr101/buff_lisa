import 'package:flutter/cupertino.dart';

import '../Files/Other/global.dart' as global;

/// ChangeNotifier saving changes and information of the [CameraPage] Widget
class CameraNotifier with ChangeNotifier {
  int currentCameraIndex = 0;

  int get getCameraIndex => currentCameraIndex;

  void changeCameraIndex() {
    currentCameraIndex = (currentCameraIndex + 1) % global.cameras.length;
    notifyListeners();
  }

}