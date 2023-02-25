
import 'dart:typed_data';

import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/Other/location_class.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_pins.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:buff_lisa/Providers/date_notifier.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../Files/Other/navbar_context.dart';
import 'check_image_ui.dart';

class CheckImageWidget extends StatefulWidget {
  const CheckImageWidget({Key? key, required this.image, required this.navbarContext, required this.group}) : super(key: key);

  /// the image taken by the camera
  final Uint8List image;

  /// navbar context to navigate to map on success
  final NavBarContext navbarContext;

  /// selected group in camera
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
    if (!mounted) return;
    await Provider.of<ClusterNotifier>(context, listen: false).addOfflinePin(mona);
    if (!mounted) return;
    Provider.of<ClusterNotifier>(context, listen: false).addPin(mona);
    _postPin(mona, widget.group);
    final BottomNavigationBar navigationBar = widget.navbarContext.globalKey.currentWidget! as BottomNavigationBar;
    if (!mounted) return;
    Provider.of<DateNotifier>(context, listen: false).notifyReload();
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
    Position locationData = await LocationClass.getLocation();
    //create Pin
    Pin pin = Pin(
        latitude: locationData.latitude,
        longitude: locationData.longitude,
        id: group.getNewOfflinePinId(),
        username: global.localData.username,
        creationDate: DateTime.now(),
        group: group,
        image: image
    );
    return pin;
  }

  /// pin is send to the server
  /// on success at the server -> offline pin is deleted and replaced by the online pin
  /// CAUTION: handheld in background even when this context is destroyed -> uses navbar context
  /// TODO wait for post to server but dont make it possible to click on post twice
  Future<void> _postPin(Pin mona, Group group) async {
    try {
      final pin = await FetchPins.postPin(mona);
      Provider.of<ClusterNotifier>(widget.navbarContext.context, listen: false).deleteOfflinePin(mona);
      Provider.of<ClusterNotifier>(widget.navbarContext.context, listen: false).addPin(pin);
    } catch (e) {
      print(e);
    }

  }

}