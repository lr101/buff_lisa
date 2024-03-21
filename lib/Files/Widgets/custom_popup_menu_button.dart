import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../7_Settings/Report/report_user.dart';
import '../../Providers/cluster_notifier.dart';
import '../../Providers/date_notifier.dart';
import '../DTOClasses/pin.dart';
import '../Other/global.dart' as global;
import '../Routes/routing.dart';
import 'cusotm_alert_dialog.dart';
import 'custom_error_message.dart';

class CustomPopupMenuButton extends StatefulWidget {
  const CustomPopupMenuButton({super.key, required this.pin, required this.update});

  final Pin pin;
  final Future<void> Function()? update;

  @override
  CustomPopupMenuButtonState createState() => CustomPopupMenuButtonState();
}

class CustomPopupMenuButtonState extends State<CustomPopupMenuButton> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: widget.pin.group.groupAdmin.asyncValue(),
      builder: (context, snapshot) => PopupMenuButton(
          itemBuilder: (context){
            final list = [
              const PopupMenuItem<int>(
                value: 0,
                child: Text("Hide this user"),
              ),
              const PopupMenuItem<int>(
                value: 1,
                child: Text("Hide this post"),
              ),
              const PopupMenuItem<int>(
                value: 2,
                child: Text("Report this user"),
              ),
              const PopupMenuItem<int>(
                value: 3,
                child: Text("Report this post"),
              ),
            ];
            if (widget.pin.username == global.localData.username || (snapshot.hasData && snapshot.requireData == global.localData.username)) {
              list.add(const PopupMenuItem<int>(
                  value: 4,
                  child: Text("Delete this post as admin")
              ));
            }
            return list;

          },
          onSelected:(value){
            switch (value) {
              case 0: handleHideUsers(context);break;
              case 1: handleHidePost(context);break;
              case 2: handleReportUser(context);break;
              case 3: handleReportPost(context);break;
              case 4: handleAdminDelete(context);break;
            }
          }
      )
    );
  }

  Future<void> handleHidePost(BuildContext context) async {
    if (global.localData.username != widget.pin.username) {
      await global.localData.hiddenPosts.put(DateTime.now(), key: widget.pin.id);
      if (!mounted) return;
      await Provider.of<ClusterNotifier>(context, listen: false).hidePin(widget.pin);
      widget.update!();
    }
  }

  /// This method tries deleting the selected pin and goes back to the previous page if successful
  /// user has to select delete in dialog
  /// Works only if [activeDelete] is true
  Future<void> handleAdminDelete(BuildContext context) async{
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

  closeIfMounted(bool deleted) {
    if (deleted && mounted) {
      Provider.of<DateNotifier>(context, listen: false).notifyReload();
      Navigator.pop(context);
    } else {
      CustomErrorMessage.message(
          context: context, message: "Image could not be deleted");
    }
  }

  Future<void> handleHideUsers(BuildContext context) async {
    if (global.localData.username != widget.pin.username) {
      await global.localData.hiddenUsers.put(DateTime.now(), key: widget.pin.username);
      if (!mounted) return;
      await Provider.of<ClusterNotifier>(context, listen: false).updateFilter();
      widget.update!();
    }
  }

  Future<void> handleReportUser(BuildContext context) async {
    String username = widget.pin.username;
    if (username != global.localData.username) {
      Routing.to(context, ReportUser(content: username, title: "Report User", hintText: "Why do you want to report $username?", userText:  'Report user: $username'));
    }
  }

  Future<void> handleReportPost(BuildContext context) async {
    String username = widget.pin.username;
    if (username != global.localData.username) {
      Routing.to(context, ReportUser(content: widget.pin.id.toString(), title: "Report Content", hintText: "Why do you want to report this content?",userText: "Report content of user: $username",));
    }
  }

}