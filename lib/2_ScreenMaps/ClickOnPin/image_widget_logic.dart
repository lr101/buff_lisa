import 'package:buff_lisa/2_ScreenMaps/ClickOnPin/image_widget_ui.dart';
import 'package:buff_lisa/Files/Widgets/cusotm_alert_dialog.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;

import '../../6_Group_Search/ClickOnGroup/show_group_logic.dart';
import '../../9_Profile/profile_logic.dart';

class ShowImageWidget extends StatefulWidget {
  const ShowImageWidget({Key? key, required this.pin, required this.newPin}) : super(key: key);

  /// Boolean for showing if shown pin is a new pin and therefore an online saved pin
  /// true: Pin is an offline Pin
  /// false: Pin is a Pin that is saved on server
  final bool newPin;

  /// The Pin that is shown on this page
  final Pin pin;

  @override
  State<ShowImageWidget> createState() => ShowImageWidgetState();

}

class ShowImageWidgetState extends State<ShowImageWidget> {

  final TransformationController controller = TransformationController();

  /// Boolean for keeping track if the delete Button is usable (Clickable)
  /// Delete Button will be activated if the current user is also the user that created this pin
  /// true: Delete Button is clickable
  /// false: Delete Button is deactivated
  bool activeDelete = false;

  @override
  Widget build(BuildContext context) => ImageWidgetUI(state: this);


  /// This method tries deleting the selected pin and goes back to the previous page if successful
  /// user has to select delete in dialog
  /// Works only if [activeDelete] is true
  Future<void> handleButtonPress() async{
      if (widget.pin.username == global.localData.username) {
        BuildContext c = context;
        showDialog(context: context, builder: (context) => CustomAlertDialog(
            title: "Delete this post?",
            text1: "Cancel",
            text2: "Delete",
            onPressed: () async {
              if (widget.pin.id < 0) {
                await Provider.of<ClusterNotifier>(c, listen: false).deleteOfflinePin(widget.pin);
              } else {
                await Provider.of<ClusterNotifier>(c, listen: false).removePin(widget.pin);
              }
              if (!mounted) return;
              Navigator.pop(c);
            },
          )
        );
      }
  }

  void handleOpenUserProfile() {
    if (widget.pin.username == global.localData.username) return;
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) =>  ProfilePage(username: widget.pin.username,)
      ),
    );
  }

  void handleOpenGroup() {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) =>  ShowGroupPage(group: widget.pin.group, myGroup: true)
      ),
    );
  }

}