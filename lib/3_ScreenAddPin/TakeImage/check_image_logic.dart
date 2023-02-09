
import 'dart:typed_data';

import 'package:buff_lisa/2_ScreenMaps/maps_logic.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:buff_lisa/Files/Other/location_class.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_pins.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'check_image_ui.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;

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
  /// init save of pin offline and online
  /// closes page if offline save is successful
  /// navigates to map screen
  Future<void> handleApprove() async {
    Pin mona = await _createMona(widget.image, widget.group);
    await Provider.of<ClusterNotifier>(widget.io.context, listen: false).addOfflinePin(mona);
    Provider.of<ClusterNotifier>(widget.io.context, listen: false).addPin(mona);
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
    LocationData locationData = await LocationClass.getLocation();
    //create Pin
    Pin pin = Pin(
        latitude: locationData.latitude!,
        longitude: locationData.longitude!,
        id: group.getNewOfflinePinId(),
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
    try {
      final pin = await FetchPins.postPin(mona);
      Provider.of<ClusterNotifier>(widget.io.context, listen: false).deleteOfflinePin(mona);
      Provider.of<ClusterNotifier>(widget.io.context, listen: false).addPin(pin);
    } catch (e) {
      print(e);
    }

  }

}