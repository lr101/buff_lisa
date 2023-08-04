
import 'dart:typed_data';

import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/Other/location_class.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_pins.dart';
import 'package:buff_lisa/Files/Widgets/custom_error_message.dart';
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

  /// flag for preventing multiple uploads
  bool uploading = false;

  /// on button press of approve button
  /// init save of pin offline and online
  /// closes page if offline save is successful
  /// navigates to map screen
  Future<void> handleApprove() async {
    _tryUpload(widget.navbarContext.context);
    final BottomNavigationBar navigationBar = widget.navbarContext.globalKey.currentWidget! as BottomNavigationBar;
    Provider.of<DateNotifier>(context, listen: false).notifyReload();
    Provider.of<ClusterNotifier>(context, listen: false).activateGroup(widget.group);
    Navigator.pop(widget.navbarContext.context);
    navigationBar.onTap!(2);
  }

  Future<void> _tryUpload(BuildContext context) async {
    Pin mona = await _createMona(widget.image, widget.group);
    if (context.mounted) {
      Provider.of<ClusterNotifier>(context, listen: false).addOfflinePin(mona);
      await FetchPins.postPin(mona).then((value) {
        Provider.of<ClusterNotifier>(context,listen: false).deleteOfflinePinAndAddToOnline(value, mona);
      }, onError: (_) => _sendMessage(context));
    }
  }
  _sendMessage(BuildContext context) {
    CustomErrorMessage.message(context: context, message: "Error while uploading, pin is saved offline");
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

}