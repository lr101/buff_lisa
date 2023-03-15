import 'package:buff_lisa/6_Group_Search/ClickOnGroup/ClickOnEdit/edit_group_logic.dart';
import 'package:buff_lisa/6_Group_Search/ClickOnGroup/show_group_ui.dart';
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/ServerCalls/fetch_groups.dart';
import 'package:buff_lisa/Files/Widgets/custom_error_message.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../../9_Profile/profile_logic.dart';
import '../../Files/DTOClasses/ranking.dart';
import '../../Providers/theme_provider.dart';

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

  bool loaded = false;

  List<Ranking>? ranking;

  PagingController<dynamic, Widget> controller = PagingController(firstPageKey: 0, invisibleItemsThreshold: 50);

  @override
  Widget build(BuildContext context) => ShowGroupUI(state: this);

   @override
   void initState() {
     super.initState();
     controller.addPageRequestListener((pageKey) async {
         ranking ??= await ((widget.group.visibility != 0 && !widget.myGroup) ? Future(() => []) : widget.group.members.asyncValue());
         if (pageKey + 50 < ranking!.length) {
           controller.appendPage(List.generate(50, (index) => buildCard(index + pageKey as int)), pageKey + 50);
         } else {
           controller.appendLastPage(List.generate(ranking!.length - pageKey as int, (index) => buildCard(index + pageKey as int)));
         }
       });
   }

  Widget buildCard(int index) {
    Ranking member = ranking![index];
    String adminString = "";
    if (member.username == widget.group.groupAdmin.syncValue) adminString = "(admin)";
    return GestureDetector(
      onTap: () => handleOpenUserProfile(member.username),
      child: Card(
          color: (member.username == global.localData.username) ? Provider.of<ThemeNotifier>(context, listen: false).getCustomTheme.c1 : null,
          child: ListTile(
            leading: Text("${index + 1}. "),
            title: Text("${member.username} $adminString"),
            trailing: Text("${member.points} points"),
          )
      ),
    );
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
    if (widget.group.groupAdmin.syncValue == global.localData.username && (await widget.group.members.asyncValue()).length > 1) {
      if (!mounted) return;
      CustomErrorMessage.message(context: context, message: "You can't leave a group as admin");
    } else {
      FetchGroups.leaveGroup(widget.group.groupId).then((value) {
        if (value) {
          Provider.of<ClusterNotifier>(context, listen: false).removeGroup(
              widget.group);
          Navigator.pop(context);
        }
      });
    }
  }

  /// close context
  Future<void> close() async {
    Navigator.pop(context, {"joined" : false});
  }

  /// opens the edit page for admin if the current user is the groups admin
  Future<void> editAsAdmin() async {
    if (widget.group.groupAdmin.syncValue != null && global.localData.username == widget.group.groupAdmin.syncValue) {
      await Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => EditGroupPage(group: widget.group)
        ),
      );
      //trigger rebuild
      setState(() {});
    }
  }

  void handleOpenUserProfile(String username) {
    if (username == global.localData.username) return;
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => ProfilePage(username: username,)
      ),
    );
  }

}