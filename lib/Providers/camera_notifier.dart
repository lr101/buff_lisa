import 'package:flutter/cupertino.dart';

import '../Files/Other/global.dart' as global;

/// ChangeNotifier saving changes and information of the [CameraPage] Widget
class CameraNotifier with ChangeNotifier {

  /// index of the currently selected camera
  int currentCameraIndex = 0;

  /// get method of [currentCameraIndex]
  int get getCameraIndex => currentCameraIndex;

  /// set method of [currentCameraIndex]
  /// cycles through all available cameras
  /// NOTIFIES CHANGES
  void changeCameraIndex() {
    currentCameraIndex = (currentCameraIndex + 1) % global.cameras.length;
    notifyListeners();
  }

}