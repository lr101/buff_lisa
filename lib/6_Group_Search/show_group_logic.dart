import 'package:buff_lisa/6_Group_Search/show_group_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Files/DTOClasses/group.dart';
import '../Files/DTOClasses/ranking.dart';
import '../Files/ServerCalls/fetch_groups.dart';
import '../Files/global.dart' as global;
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

  /// returns the members of this group in a list
  /// if the group is private and the current user is not a member a lock icon is shown
  /// if the group is public or the current user is a member, a list with all members sorted by contributed post is returned
  Widget getMembers() {
    if  (widget.group.visibility != 0 && !widget.myGroup) {
      return Row(
        children: const [
          Text("Members:"),
          Icon(Icons.lock)
        ],
      );
    } else {
      return FutureBuilder<List<Ranking>>(
          future: widget.group.getMembers(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _buildList();
            } else {
              return const CircularProgressIndicator();
            }
          }
      );
    }
  }

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

  /// opens the edit page for admin if the current user is the groups admin
  Future<void> editAsAdmin() async {
    if (widget.group.groupAdmin != null && global.username == widget.group.groupAdmin) {
      print("editing allowed");
      //TODO new page to edit
    }
  }

  /// builds the  list of members of the group
  /// members are sorted by the most amount of posts
  /// the member, index and points are being shown
  Widget _buildList() {
    List<Ranking> members = widget.group.members!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Members: "),
        ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: widget.group.members!.length,
            itemBuilder: (_, index) {
              String adminString = "";
              if (members[index].username == widget.group.groupAdmin!) adminString = "(admin)";
              return Card(
                  child: ListTile(
                    leading: Text("${index + 1}. "),
                    title: Text("${members[index].username} $adminString"),
                    trailing: Text("${members[index].points} points"),
                  )
              );
            }
        )
      ],
    );
  }

}