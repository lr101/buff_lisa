import 'dart:typed_data';

import 'package:buff_lisa/3_ScreenAddPin/camera_ui.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_pins.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import '../2_ScreenMaps/maps_logic.dart';
import '../Files/DTOClasses/group.dart';
import '../Files/DTOClasses/pin.dart';
import '../Files/global.dart' as global;
import '../Files/location_class.dart';
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

  @override
  Widget build(BuildContext context) => CameraUI(state: this);

  /// opens a new page to check image
  /// 1. on approval of the user the image is saved as online pin
  /// 2. pin in send to the server
  /// 3. on success at the server -> offline pin is deleted and replaced by the online pin
  Future<void> handlePictureTaken(Uint8List image, ProviderContext io) async {
    Map<String, dynamic> result = await Navigator.of(widget.io.context).push(
      MaterialPageRoute(
          builder: (context) => CheckImageWidget(image: image,)),
    );
    if (result["approve"] != null && result["approve"] as bool) {
      Group group = result["type"] as Group;
      Pin mona = await _createMona(image, group);
      await Provider.of<ClusterNotifier>(widget.io.context, listen: false).addOfflinePin(mona);
      _postPin(mona, group);
      final BottomNavigationBar navigationBar = io.globalKey.currentWidget! as BottomNavigationBar;
      navigationBar.onTap!(2);
    }
  }

  /// creates a Pin (mona) by accessing the location of the user
  Future<Pin> _createMona(Uint8List image, Group group) async {
    int length = Provider.of<ClusterNotifier>(context, listen: false).getOfflinePins().length;
    LocationData locationData = await LocationClass.getLocation();
    //create Pin
    Pin pin = Pin(
        latitude: locationData.latitude!,
        longitude: locationData.longitude!,
        id: length,
        username: global.username,
        creationDate: DateTime.now(),
        group: group,
        image: image
    );
    return pin;
  }

  /// pin is send to the server
  /// on success at the server -> offline pin is deleted and replaced by the online pin
  Future<void> _postPin(Pin mona, Group group) async {
    final pin = await FetchPins.postPin(mona);
    Provider.of<ClusterNotifier>(widget.io.context, listen: false).deleteOfflinePin(mona);
    Provider.of<ClusterNotifier>(widget.io.context, listen: false).addPin(pin);
  }

  /// returns the width of the camera to fit a 16:9 camera preview perfectly
  double getWidth() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    if (width * 16.0/9.0 > height) {
      width = height * 9.0/16.0;
    }
    return width;
  }

  /// returns the height of the camera to fit a 16:9 camera preview perfectly
  double getHeight() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    if (width * 16.0/9.0 <= height) {
      height = width * 16.0/9.0;
    }
    return height;
  }

}