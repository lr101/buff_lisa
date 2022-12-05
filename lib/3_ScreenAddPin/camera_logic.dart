import 'dart:typed_data';

import 'package:buff_lisa/3_ScreenAddPin/camera_ui.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_pins.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../2_ScreenMaps/maps_logic.dart';
import '../Files/DTOClasses/group.dart';
import '../Files/Other/global.dart' as global;
import '../Providers/camera_group_notifier.dart';
import '../Providers/camera_notifier.dart';
import '../Providers/cluster_notifier.dart';
import 'check_image_logic.dart';

class CameraWidget extends StatefulWidget {

  /// TODO is it needed?
  final ProviderContext io;

  const CameraWidget({super.key, required this.io});

  @override
  State<CameraWidget> createState() => CameraControllerWidget();
}

class CameraControllerWidget extends State<CameraWidget> {

  /// opens a new page to check image
  /// 1. on approval of the user the image is saved as online pin
  /// 2. pin in send to the server
  /// 3. on success at the server -> offline pin is deleted and replaced by the online pin

  late double ratio;
  double scaleFactor = 1.0;
  double basScaleFactor = 1.0;
  late double _minZoom;
  late double _maxZoom;
  bool init = false;
  final ResolutionPreset resolution = ResolutionPreset.medium;
  late List<Group> groups;



  @override
  Widget build(BuildContext context) {
    final state = this;
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: CameraNotifier(),
          ),
          ChangeNotifierProvider.value(
            value: CameraGroupNotifier(),
          ),
        ],
        builder: ((context, child) => CameraUI(state: state))
    );
  }

  late CameraController controller;
  Future<void> initializeControllerFuture(context) async {
    try {
      groups = Provider.of<ClusterNotifier>(context).getGroups;
      controller = CameraController(global.cameras[Provider.of<CameraNotifier>(context).getCameraIndex] ,resolution );
      await controller.initialize();
      init = true;
      ratio = controller.value.aspectRatio;
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

  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> takePicture(context) async {
    if (!init) await initializeControllerFuture(context);
    final image = await controller.takePicture();
    try {
      Uint8List bytes;
      if (kIsWeb) {
        bytes = await FetchPins.fetchImageFromBrowserCash(image.path);
      } else {
        bytes = await image.readAsBytes();
      }
      Group group = groups[Provider.of<CameraGroupNotifier>(context, listen: false).currentGroupIndex];
      Navigator.of(widget.io.context).push(
        MaterialPageRoute(
            builder: (context) => CheckImageWidget(image: bytes, io: widget.io, group: group,)),
      );
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

  Future<void> handleCameraChange(context) async {
    Provider.of<CameraNotifier>(context, listen: false).changeCameraIndex();
  }

  void onPageChange(index, context) {
    Provider.of<CameraGroupNotifier>(context, listen: false).setGroupIndex(index);
  }
}