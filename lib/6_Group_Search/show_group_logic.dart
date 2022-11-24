import 'package:buff_lisa/6_Group_Search/show_group_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Files/global.dart' as global;
import '../Files/DTOClasses/group.dart';
import '../Files/DTOClasses/ranking.dart';
import '../Files/fetch_groups.dart';
import '../Providers/cluster_notifier.dart';

class ShowGroupPage extends StatefulWidget {
  const ShowGroupPage({super.key, required this.group, required this.myGroup});

  final Group group;
  final bool myGroup;

  @override
  ShowGroupPageState createState() => ShowGroupPageState();
}

class ShowGroupPageState extends State<ShowGroupPage> {

  @override
  Widget build(BuildContext context) => ShowGroupUI(state: this);

  Widget getMembers() {
    if  (widget.group.visibility != 0) {
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

  void joinPublicGroup() {
    FetchGroups.joinGroup(widget.group.groupId, null).then((value) {
      Provider.of<ClusterNotifier>(context, listen: false).addGroup(value);
      Navigator.pop(context, {"joined" : true});
    });
  }

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

  Future<void> leaveGroup() async {
    FetchGroups.leaveGroup(widget.group.groupId).then((value) {
      if (value) {
        Provider.of<ClusterNotifier>(context, listen: false).removeGroup(widget.group);
        Navigator.pop(context);
      }
    });
  }

  Future<void> editAsAdmin() async {
    if (widget.group.groupAdmin != null && global.username == widget.group.groupAdmin) {
      print("editing allowed");
      //TODO new page to edit
    }
  }

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