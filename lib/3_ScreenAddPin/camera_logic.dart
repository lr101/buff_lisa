
import 'package:buff_lisa/3_ScreenAddPin/camera_ui.dart';
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/ServerCalls/fetch_pins.dart';
import 'package:buff_lisa/Files/Widgets/custom_error_message.dart';
import 'package:buff_lisa/Files/Widgets/custom_image_picker.dart';
import 'package:buff_lisa/Providers/camera_group_notifier.dart';
import 'package:buff_lisa/Providers/camera_icon_notifier.dart';
import 'package:buff_lisa/Providers/camera_notifier.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mutex/mutex.dart';
import 'package:native_exif/native_exif.dart';
import 'package:provider/provider.dart';
import 'package:super_tooltip/super_tooltip.dart';

import '../Files/Other/local_data.dart';
import '../Files/Other/navbar_context.dart';
import '../Files/Routes/routing.dart';
import 'TakeImage/check_image_logic.dart';

class CameraWidget extends StatefulWidget {

  /// used to redirect to map after image successfully approved
  final NavBarContext navbarContext;

  const CameraWidget({super.key, required this.navbarContext});

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

  /// controller of group selector list
  final PageController pageController = PageController(viewportFraction: 0.3);

  final _m = Mutex();

  @override
  late BuildContext context;

  final tooltipController = SuperTooltipController();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CameraNotifier(),),
          ChangeNotifierProvider(create: (_) => CameraGroupNotifier(),),
          ChangeNotifierProvider(create: (_) => CameraIconNotifier(),),
        ],
        builder: ((context, child) {
          this.context = context;
          return CameraUI(state: this);
          }
        )
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!global.localData.getTip(Tips.uploadFromGallery)) {
        tooltipController.showTooltip();
        global.localData.setTip(Tips.uploadFromGallery);
      }
    });
  }

  /// initializes the camera and its controller and saves relevant values of this camera to the corresponding attributes
  Future<void> initializeControllerFuture(context) async {
    try {
      groups = Provider.of<ClusterNotifier>(context).getGroups;
      init = false;
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
      if (!init) {
        CustomErrorMessage.message(context: context, message: "Something went wrong while initializing the camera");
      } else {
        CustomErrorMessage.message(context: context, message: "No zoom available");
      }
    }
  }

  /// disposes the camera and its controller
  @override
  void dispose() {
    if (init) controller.dispose();
    super.dispose();
  }

  /// takes an image via the controller
  /// selected group and image byte list used for showing [CheckImageWidget] page
  Future<void> takePicture(context, index) async {
    if (index != Provider
        .of<CameraGroupNotifier>(context, listen: false)
        .currentGroupIndex) {
      pageController.animateToPage(
          index, duration: const Duration(milliseconds: 200),
          curve: Curves.easeIn);
      return;
    }
    _m.protect(() async{
      if (init) {
        final image = await controller.takePicture();
        try {
          Uint8List bytes;
          if (kIsWeb) {
            bytes = await FetchPins.fetchImageFromBrowserCash(image.path);
          } else {
            bytes = await image.readAsBytes();
          }
          await routeToCheckImage(bytes);
        } catch (e) {
          CustomErrorMessage.message(context: context,
              message: "Something went wrong while taking the picture");
        }
      }
    });
  }

  Future<void> routeToCheckImage(Uint8List bytes, [ExifLatLong? coord]) async {
    Group group = groups[Provider.of<CameraGroupNotifier>(context, listen: false).currentGroupIndex];
    await Routing.to(context,  CheckImageWidget(image: bytes, navbarContext: widget.navbarContext, group: group, coordinates: coord,));
  }

  /// switch the flash mode to the next
  void switchFlash() {
    if(init) controller.setFlashMode(Provider.of<CameraIconNotifier>(context, listen: false).nextFlashMode());
  }

  Future<void> upload() async {
    final imageFile = await CustomImagePicker.pick(context: context);
    final exif = await Exif.fromPath(imageFile!.path);
    final coord = await exif.getLatLong();
    final bytes = await imageFile.readAsBytes();
    if (coord != null) {
      await routeToCheckImage(bytes, coord);
    } else {
      if (!mounted) return;
      CustomErrorMessage.message(context: context, message: "Coordination could not be read from image metadata");
    }

  }


  /// uses the camera zoom if zoom is inside [_minZoom] and [_maxZoom]
  Future<void> handleZoom(ScaleUpdateDetails scale) async{
    if (scale.scale * basScaleFactor <= _maxZoom && scale.scale * basScaleFactor >= _minZoom) {
      scaleFactor = basScaleFactor * scale.scale;
      await controller.setZoomLevel(scaleFactor);
    }
  }

  /// changes the camera on double tab via provider and its listeners
  Future<void> handleCameraChange(context, [int? index]) async {
    if (init) {
      if (index == null) {
        Provider.of<CameraNotifier>(context, listen: false).changeCameraIndex();
      } else {
        Provider.of<CameraNotifier>(context, listen: false).changeCameraToIndex(index);
      }
    }
  }

  /// changes the selected group index via provider
  void onPageChange(index, context) {
    Provider.of<CameraGroupNotifier>(context, listen: false).setGroupIndex(index);
  }
}