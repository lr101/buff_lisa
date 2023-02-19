import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../7_Settings/Report/report_user.dart';
import '../../Providers/cluster_notifier.dart';
import '../DTOClasses/hive_handler.dart';

import '../Other/global.dart' as global;

import '../DTOClasses/pin.dart';

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
    return PopupMenuButton(
        itemBuilder: (context){
          return [
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
        },
        onSelected:(value){
          switch (value) {
            case 0: handleHideUsers(context);break;
            case 1: handleHidePost(context);break;
            case 2: handleReportUser(context);break;
            case 3: handleReportPost(context);break;
          }
        }
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
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ReportUser(content: username, title: "Report User", hintText: "Why do you want to report $username?", userText:  'Report user: $username')),
      );
    }
  }

  Future<void> handleReportPost(BuildContext context) async {
    String username = widget.pin.username;
    if (username != global.localData.username) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ReportUser(content: widget.pin.id.toString(), title: "Report Content", hintText: "Why do you want to report this content?",userText: "Report content of user: $username",)),
      );
    }
  }

}