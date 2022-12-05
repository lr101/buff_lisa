
import 'dart:typed_data';

import 'package:buff_lisa/2_ScreenMaps/maps_logic.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import '../Files/DTOClasses/group.dart';
import '../Files/DTOClasses/pin.dart';
import '../Files/Other/location_class.dart';
import '../Files/ServerCalls/fetch_pins.dart';
import '../Providers/cluster_notifier.dart';
import 'check_image_ui.dart';
import '../Files/Other/global.dart' as global;

class CheckImageWidget extends StatefulWidget {
  const CheckImageWidget({Key? key, required this.image, required this.io, required this.group}) : super(key: key);

  /// the image shown for checking if correct
  final Uint8List image;

  final ProviderContext io;

  final Group group;

  @override
  State<StatefulWidget> createState() => StateCheckImageWidget();
}


class StateCheckImageWidget extends State<CheckImageWidget>{

  @override
  Widget build(BuildContext context)  => CheckImageIU(state: this);

  /// on button press of approve button
  /// returns back to the camera page with the type information selected by the user
  Future<void> handleApprove() async {
    Pin mona = await _createMona(widget.image, widget.group);
    await Provider.of<ClusterNotifier>(widget.io.context, listen: false).addOfflinePin(mona);
    _postPin(mona, widget.group);
    final BottomNavigationBar navigationBar = widget.io.globalKey.currentWidget! as BottomNavigationBar;
    if (!mounted) return;
    Navigator.pop(context);
    navigationBar.onTap!(2);

  }

  /// on button press of back button
  /// returns back to the camera
  void handleBack() {
    Navigator.pop(context);
  }

  /// builds the image widget
  Future<Widget> handleFutureImage() async{
    return Image.memory(widget.image);
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

}