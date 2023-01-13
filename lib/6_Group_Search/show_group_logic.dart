import 'dart:typed_data';

import 'package:buff_lisa/6_Group_Search/edit_group_logic.dart';
import 'package:buff_lisa/6_Group_Search/show_group_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Files/DTOClasses/group.dart';
import '../Files/DTOClasses/ranking.dart';
import '../Files/ServerCalls/fetch_groups.dart';
import '../Files/Other/global.dart' as global;
import '../Providers/cluster_notifier.dart';

class ShowGroupPage extends StatefulWidget {
  const ShowGroupPage({super.key, required this.group, required this.myGroup});

  /// Group that is displayed in this widget
  final Group group;

  /// Current user is member of this group
  /// true: Current user is a member
  /// false: Current user is not a member
  final bool myGroup;

  @override
  ShowGroupPageState createState() => ShowGroupPageState();
}

class ShowGroupPageState extends State<ShowGroupPage> {

  @override
  Widget build(BuildContext context) => ShowGroupUI(state: this);

  /// joins a public group and closes the current context
  /// Method can only be called when the group is public and user is not a member
  void joinPublicGroup() {
    FetchGroups.joinGroup(widget.group.groupId, null).then((value) {
      Provider.of<ClusterNotifier>(context, listen: false).addGroup(value);
      Navigator.pop(context, {"joined" : true});
    });
  }

  /// joins a private group by getting the invite code from the text field and closes the current context
  /// Method can only be called when the group is private and user is not a member
  void joinPrivateGroup(TextEditingController controller)  {
    try {
      FetchGroups.joinGroup(widget.group.groupId, controller.text).then((value) {
        Provider.of<ClusterNotifier>(context, listen: false).addGroup(value);
        Navigator.pop(context, {"joined" : true});
      });
    } catch(e) {
      //TODO wrong invite code
    }
  }

  /// leaves the group and closes the current context
  /// Method can only be called if the current user is a member of this group
  Future<void> leaveGroup() async {
    FetchGroups.leaveGroup(widget.group.groupId).then((value) {
      if (value) {
        Provider.of<ClusterNotifier>(context, listen: false).removeGroup(widget.group);
        Navigator.pop(context);
      }
    });
  }

  /// close context
  Future<void> close() async {
    Navigator.pop(context, {"joined" : false});
  }

  /// opens the edit page for admin if the current user is the groups admin
  Future<void> editAsAdmin() async {
    if (widget.group.groupAdmin.syncValue != null && global.username == widget.group.groupAdmin.syncValue) {
      await Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => EditGroupPage(group: widget.group)
        ),
      );
      //trigger rebuild
      setState(() {});
    }
  }

}