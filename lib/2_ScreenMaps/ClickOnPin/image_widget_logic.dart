import 'package:buff_lisa/2_ScreenMaps/ClickOnPin/image_widget_ui.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/Widgets/cusotm_alert_dialog.dart';
import 'package:buff_lisa/Files/Widgets/custom_error_message.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../6_Group_Search/ClickOnGroup/show_group_logic.dart';
import '../../9_Profile/profile_logic.dart';
import '../../Files/Routes/routing.dart';
import '../../Providers/date_notifier.dart';

class ShowImageWidget extends StatefulWidget {
  const ShowImageWidget({super.key, required this.pin});

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
        await showDialog<bool>(context: context, builder: (_) =>
            CustomAlertDialog(
              title: "Delete this post?",
              text1: "Cancel",
              text2: "Delete",
              onPressed: () async {
                bool deleted = false;
                try {
                  if (widget.pin.id < 0) {
                    await Provider.of<ClusterNotifier>(c, listen: false)
                        .deleteOfflinePin(widget.pin);
                    deleted = true;
                  } else {
                    deleted = await Provider.of<ClusterNotifier>(c, listen: false)
                        .removePin(widget.pin);
                  }
                } catch (_) {
                  deleted = false;
                }
                closeIfMounted(deleted);
              },
            )
        );

      }
  }

  closeIfMounted(bool deleted) {
    if (deleted && mounted) {
      Provider.of<DateNotifier>(context, listen: false).notifyReload();
      Navigator.pop(context);
    } else {
      CustomErrorMessage.message(
          context: context, message: "Image could not be deleted");
    }
  }

  void handleOpenUserProfile() {
    if (widget.pin.username == global.localData.username) return;
    Routing.to(context, ProfilePage(username: widget.pin.username,));
  }

  void handleOpenGroup() {
    Routing.to(context,   ShowGroupPage(group: widget.pin.group, myGroup: true));
  }

}