
import 'dart:typed_data';

import 'package:buff_lisa/5_Feed/FeedCard/feed_card_logic.dart';
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/Other/location_class.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_pins.dart';
import 'package:buff_lisa/Files/Widgets/cusotm_alert_dialog.dart';
import 'package:buff_lisa/Files/Widgets/custom_error_message.dart';
import 'package:buff_lisa/Files/settings_ui/src/utils/theme_provider.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:buff_lisa/Providers/date_notifier.dart';
import 'package:buff_lisa/Providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:native_exif/native_exif.dart';
import 'package:provider/provider.dart';
import 'package:select_dialog/select_dialog.dart';

import '../../Files/Other/navbar_context.dart';
import '../../Files/Widgets/custom_list_tile.dart';
import '../camera_ui.dart';
import 'check_image_ui.dart';

class CheckImageWidget extends StatefulWidget {
  const CheckImageWidget({Key? key, required this.image, required this.navbarContext, required this.group, this.coordinates}) : super(key: key);

  /// the image taken by the camera
  final Uint8List image;

  /// navbar context to navigate to map on success
  final NavBarContext navbarContext;

  final  ExifLatLong? coordinates;

  /// selected group in camera
  final Group group;

  @override
  State<StatefulWidget> createState() => StateCheckImageWidget();
}


class StateCheckImageWidget extends State<CheckImageWidget>{

  @override
  Widget build(BuildContext context)  => CheckImageIU(state: this);

  Pin? pin;

  final TransformationController controller = TransformationController();

  late Group selectedGroup;

  /// flag for preventing multiple uploads
  bool uploading = false;

  @override
  void initState() {
    super.initState();
    selectedGroup = widget.group;
  }

  /// on button press of approve button
  /// init save of pin offline and online
  /// closes page if offline save is successful
  /// navigates to map screen
  Future<void> handleApprove() async {
    _tryUpload(widget.navbarContext.context);
    final BottomNavigationBar navigationBar = widget.navbarContext.globalKey.currentWidget! as BottomNavigationBar;
    Provider.of<DateNotifier>(context, listen: false).notifyReload();
    Provider.of<ClusterNotifier>(context, listen: false).activateGroup(selectedGroup);
    Navigator.pop(widget.navbarContext.context);
    navigationBar.onTap!(2);
  }

  Future<void> _tryUpload(BuildContext context) async {
    Pin mona = await _createMona(widget.image, selectedGroup);
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
    pin = await _createMona(widget.image, selectedGroup);
    return FeedCard(pin: pin!);
  }

  /// creates a Pin (mona) by accessing the location of the user
  Future<Pin> _createMona(Uint8List image, Group group) async {
    if (this.pin != null) return this.pin!;
    double lat;
    double long;
    if (widget.coordinates != null) {
      lat = widget.coordinates!.latitude;
      long = widget.coordinates!.longitude;
    } else {
      Position locationData = await LocationClass.getLocation();
      lat = locationData.latitude;
      long = locationData.longitude;
    }
    //create Pin
    Pin pin = Pin(
        latitude: lat,
        longitude: long,
        id: group.getNewOfflinePinId(),
        username: global.localData.username,
        creationDate: DateTime.now().toUtc(),
        group: selectedGroup,
        image: image
    );
    return pin;
  }

    Future<void> handleEdit() async {
      await SelectDialog.showModal<Group>(
        context,
        showSearchBox: false,
        label: "Change Group",
        selectedValue: selectedGroup,
        itemBuilder: (context, group, b) => CustomListTile.fromGroup(group),
        items: Provider.of<ClusterNotifier>(context, listen: false).getGroups,
        onChange: (group) {
          setState(() {
            selectedGroup = group;
            pin?.group = group;
          });
        },
      );
    setState(() {});

  }

}