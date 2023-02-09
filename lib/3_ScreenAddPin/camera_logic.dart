
import 'package:buff_lisa/3_ScreenAddPin/camera_ui.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_pins.dart';
import 'package:buff_lisa/Providers/camera_icon_notifier.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../2_ScreenMaps/maps_logic.dart';
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Providers/camera_group_notifier.dart';
import 'package:buff_lisa/Providers/camera_notifier.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'TakeImage/check_image_logic.dart';

class CameraWidget extends StatefulWidget {

  /// TODO is it needed?
  final ProviderContext io;

  const CameraWidget({super.key, required this.io});

  @override
  State<CameraWidget> createState() => CameraControllerWidget();
}

class CameraControllerWidget extends State<CameraWidget> {

  /// nativ ratio of the selected camera
  late double ratio;

  /// value of the current zoom
  double scaleFactor = 1.0;

  /// value of the zoom when not zoomed
  double basScaleFactor = 1.0;

  /// fixed min zoom value of the selected camera
  late double _minZoom;

  /// fixed max zoom value of the selected camera
  late double _maxZoom;

  /// flag for an initialized camera controller
  /// true: controller is initialized
  /// false: controller is not initialized
  bool init = false;

  /// fixed constant value of the resolution preset (image quality) of the taken images of the camera
  final ResolutionPreset resolution = ResolutionPreset.medium;

  /// list of possible groups shown for selection
  late List<Group> groups;

  /// the camera controller
  /// used for showing the preview, zoom and taking images
  late CameraController controller;

  @override
  late BuildContext context;

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
          ChangeNotifierProvider.value(
            value: CameraIconNotifier(),
          ),
        ],
        builder: ((context, child) {
          this.context = context;
          return CameraUI(state: this);
          }
        )
    );
  }

  /// initializes the camera and its controller and saves relevant values of this camera to the corresponding attributes
  Future<void> initializeControllerFuture(context) async {
    try {
      groups = Provider.of<ClusterNotifier>(context).getGroups;
      controller = CameraController(global.cameras[Provider.of<CameraNotifier>(context).getCameraIndex] ,resolution,enableAudio: false );
      await controller.initialize();
      init = true;
      ratio = controller.value.aspectRatio;
      _minZoom = await controller.getMinZoomLevel();
      _maxZoom = await controller.getMaxZoomLevel();
      controller.setFlashMode(Provider.of<CameraIconNotifier>(context, listen: false).getFlashMode());
    } catch(_) {
      _minZoom = basScaleFactor;
      _maxZoom = basScaleFactor;
    }
  }

  /// disposes the camera and its controller
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// takes an image via the controller
  /// selected group and image byte list used for showing [CheckImageWidget] page
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

  void switchFlash() {
    controller.setFlashMode(Provider.of<CameraIconNotifier>(context, listen: false).nextFlashMode());
  }

  /// returns the width of the camera to fit a 16:9 camera preview perfectly
  double getWidth(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - global.barHeight;
    if (width * ratio > height) {
      width = height * ratio;
    }
    return width;
  }

  /// returns the height of the camera to fit a 16:9 camera preview perfectly
  double getHeight(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height - global.barHeight;
    if (width * ratio <= height) {
      height = width * ratio;
    }
    return height;
  }

  /// uses the camera zoom if zoom is inside [_minZoom] and [_maxZoom]
  Future<void> handleZoom(ScaleUpdateDetails scale) async{
    if (scale.scale * basScaleFactor <= _maxZoom && scale.scale * basScaleFactor >= _minZoom) {
      scaleFactor = basScaleFactor * scale.scale;
      await controller.setZoomLevel(scaleFactor);
    }
  }

  /// changes the camera on double tab via provider and its listeners
  Future<void> handleCameraChange(context) async {
    Provider.of<CameraNotifier>(context, listen: false).changeCameraIndex();
  }

  /// changes the selected group index via provider
  void onPageChange(index, context) {
    Provider.of<CameraGroupNotifier>(context, listen: false).setGroupIndex(index);
  }
}