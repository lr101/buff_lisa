import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/Other/local_data.dart';
import 'package:flutter/cupertino.dart';

/// ChangeNotifier saving changes and information of the [CameraPage] Widget
class CameraNotifier with ChangeNotifier {

  /// index of the currently selected camera
  int currentCameraIndex = global.localData.getCamera(CameraOfflineValues.cameraSelection);

  /// get method of [currentCameraIndex]
  int get getCameraIndex => currentCameraIndex;

  /// nativ ratio of the selected camera
  late double ratio;

  /// set method of [currentCameraIndex]
  /// cycles through all available cameras
  /// NOTIFIES CHANGES
  void changeCameraIndex() {
    currentCameraIndex = (currentCameraIndex + 1) % global.cameras.length;
    global.localData.setCamera(CameraOfflineValues.cameraSelection, currentCameraIndex);
    notifyListeners();
  }

  void changeCameraToIndex(int index) {
    currentCameraIndex = index;
    global.localData.setCamera(CameraOfflineValues.cameraSelection, currentCameraIndex);
    notifyListeners();
  }

}