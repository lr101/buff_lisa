import 'dart:convert';
import 'dart:io';
import '../Files/global.dart' as global;
import 'package:buff_lisa/3_ScreenAddPin/camera_ui.dart';
import 'package:camera_camera/camera_camera.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import '../Files/location_class.dart';
import '../Files/pin.dart';
import '../Files/provider_context.dart';
import '../Files/restAPI.dart';
import '../Providers/cluster_notifier.dart';
import '../Providers/points_notifier.dart';
import 'check_image_logic.dart';


class CameraWidget extends StatefulWidget {
  final ProviderContext io;

  const CameraWidget({super.key, required this.io});

  @override
  State<CameraWidget> createState() => CameraControllerWidget();
}

class CameraControllerWidget extends State<CameraWidget> {

  @override
  Widget build(BuildContext context) => CameraUI(state: this);

  /// opens a new page to check image
  /// 1. on approval of the user the image is saved as online pin
  /// 2. pin in send to the server
  /// 3. on success at the server -> offline pin is deleted and replaced by the online pin
  Future<void> handlePictureTaken(File image, ProviderContext io) async {
    Map<String, dynamic> result = await Navigator.of(widget.io.context).push(
      MaterialPageRoute(
          builder: (context) => CheckImageWidget(image: image,)),
    );
    if (result["approve"] as bool) {
      SType type = result["type"] as SType;
      Mona mona = await _createMona(image, type);
      await Provider.of<ClusterNotifier>(widget.io.context, listen: false).addOfflinePin(mona);
      Provider.of<PointsNotifier>(widget.io.context, listen: false).incrementPoints();
      Provider.of<PointsNotifier>(widget.io.context, listen: false).incrementNumAll();
      _postPin(mona);
      final BottomNavigationBar navigationBar = io.globalKey.currentWidget! as BottomNavigationBar;
      navigationBar.onTap!(0);
    }
  }

  /// creates a Mona by accessing the location of the user
  Future<Mona> _createMona(File image, SType type) async {
    int length = Provider.of<ClusterNotifier>(context, listen: false).getOfflinePins().length;
    LocationData locationData = await LocationClass.getLocation();
    //create Pin
    Pin pin = Pin(
        latitude: locationData.latitude!,
        longitude: locationData.longitude!,
        id: length,
        username: global.username,
        type: type,
        creationDate: DateTime.now()
    );
    //create Mona
    return Mona(image: XFile.fromData(await image.readAsBytes()), pin: pin);
  }

  /// pin in send to the server
  /// on success at the server -> offline pin is deleted and replaced by the online pin
  Future<void> _postPin(Mona mona) async {
    HttpClientResponse response = await RestAPI.postPin(mona);
    if (response.statusCode == 201 || response.statusCode == 200) {
      response.transform(utf8.decoder).join().then((value) {
        Map<String, dynamic> json = jsonDecode(value) as Map<String, dynamic>;
        Pin pin = Pin.fromJson(json);
        Provider.of<ClusterNotifier>(widget.io.context, listen: false).deleteOfflinePin(mona.pin.id);
        Provider.of<ClusterNotifier>(widget.io.context, listen: false).addPin(pin);
      });
    }
  }

}