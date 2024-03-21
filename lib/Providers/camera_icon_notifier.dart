import 'package:buff_lisa/Files/Other/local_data.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../Files/Other/global.dart' as global;

/// ChangeNotifier saving changes and information of the [CameraPage] Widget
class CameraIconNotifier with ChangeNotifier {


  int flashMode = global.localData.getCamera(CameraOfflineValues.flashMode);

  FlashMode getFlashMode() {
    switch(flashMode) {
      case 0: return FlashMode.auto;
      case 1: return FlashMode.off;
      case 2: return FlashMode.always;
      default: return FlashMode.auto;
    }
  }

  FlashMode nextFlashMode() {
    flashMode = (flashMode + 1) % 3;
    global.localData.setCamera(CameraOfflineValues.flashMode, flashMode);
    notifyListeners();
    return getFlashMode();
  }

  Widget getFlashIcon() {
    IconData icon;
    switch(flashMode) {
      case 0: icon = Icons.flash_auto;break;
      case 1: icon = Icons.flash_off;break;
      case 2: icon = Icons.flash_on;break;
      default: icon = Icons.flash_auto;
    }
    return Icon(icon);
  }

}