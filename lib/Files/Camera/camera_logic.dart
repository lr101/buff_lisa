import 'dart:typed_data';

import 'package:buff_lisa/Files/ServerCalls/fetch_pins.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'camera_ui.dart';

import '../Other/global.dart' as global;
class CameraPage extends StatefulWidget {
  const CameraPage({super.key, required this.onImage, required this.resolution});

  final Function(Uint8List) onImage;

  final ResolutionPreset resolution;


  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {

  late double ratio;
  double scaleFactor = 1.0;
  double basScaleFactor = 1.0;
  late double _minZoom;
  late double _maxZoom;
  bool init = false;

  @override
  Widget build(context) => CameraPageUI(state: this);

  late CameraController controller;
  Future<void> initializeControllerFuture() async {
    try {
      await controller.initialize();
      init = true;
      ratio = controller.value.aspectRatio;
      DeviceOrientation orientation = controller.value.deviceOrientation;
      if (orientation == DeviceOrientation.landscapeLeft || orientation == DeviceOrientation.landscapeRight) ratio = 1.0/ratio;
      _minZoom = await controller.getMinZoomLevel();
      _maxZoom = await controller.getMaxZoomLevel();

    } catch(_) {
      _minZoom = basScaleFactor;
      _maxZoom = basScaleFactor;
    }
  }

  @override
  void initState() {
    super.initState();
    controller = CameraController(global.cameras.first ,widget.resolution);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> takePicture() async {
    if (!init) await initializeControllerFuture();
    final image = await controller.takePicture();
    try {
      Uint8List bytes;
      if (kIsWeb) {
        bytes = await FetchPins.fetchImageFromBrowserCash(image.path);
      } else {
        bytes = await image.readAsBytes();
      }
      widget.onImage(bytes);
    } catch (e) {
      print(e);
    }
  }

  /// returns the width of the camera to fit a 16:9 camera preview perfectly
  double getWidth() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - global.barHeight;
    if (width * ratio > height) {
      width = height * ratio;
    }
    return width;
  }

  /// returns the height of the camera to fit a 16:9 camera preview perfectly
  double getHeight() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - global.barHeight;
    if (width * ratio <= height) {
      height = width * ratio;
    }
    return height;
  }

  Future<void> handleZoom(ScaleUpdateDetails scale) async{
    if (scale.scale * basScaleFactor <= _maxZoom && scale.scale * basScaleFactor >= _minZoom) {
      scaleFactor = basScaleFactor * scale.scale;
      await controller.setZoomLevel(scaleFactor);
    }
  }

}