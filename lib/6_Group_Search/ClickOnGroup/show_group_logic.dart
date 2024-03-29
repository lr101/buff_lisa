import 'package:buff_lisa/6_Group_Search/ClickOnGroup/ClickOnEdit/edit_group_logic.dart';
import 'package:buff_lisa/6_Group_Search/ClickOnGroup/images_sub_page.dart';
import 'package:buff_lisa/6_Group_Search/ClickOnGroup/members_sub_page.dart';
import 'package:buff_lisa/6_Group_Search/ClickOnGroup/show_group_ui.dart';
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/ServerCalls/fetch_groups.dart';
import 'package:buff_lisa/Files/Widgets/custom_error_message.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Files/DTOClasses/ranking.dart';
import '../../Files/Other/tupel_3.dart';
import '../../Files/Routes/routing.dart';

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

class ShowGroupPageState extends State<ShowGroupPage> with SingleTickerProviderStateMixin{



  late TabController _tabController;

  late List<Tupel3> pages;

  @override
  Widget build(BuildContext context) => ShowGroupUI(state: this);

   @override
   void initState() {
     super.initState();
     pages = [
       Tupel3('Members', widget.group.visibility == 0 || widget.myGroup ? MembersSubPage(group: widget.group, myGroup: widget.myGroup,) : const SizedBox.shrink(), const Icon(Icons.groups)),
       Tupel3('Images', widget.group.visibility == 0 || widget.myGroup ? ImagesSubPage(group: widget.group,) : const SizedBox.shrink(), const Icon(Icons.image)),
     ];
     _tabController = TabController(length: pages.length, vsync: this);
   }

   Widget calcNumPosts() {
     return FutureBuilder<List<Ranking>>(
         future: () {Provider.of<ClusterNotifier>(context).getGroups; return widget.group.members.asyncValue();}(),
         builder: (context, snapshot) {
           if (snapshot.hasData) {
             if (snapshot.requireData.isEmpty) return const Icon(Icons.lock);
             int num = 0;
             for (var element in snapshot.requireData) {
               num += element.points;
             }
             return Text(num.toString());
           } else {
             return const Text("---");
           }
         },
     );
   }

   Widget calcNumMembers() {
     return FutureBuilder<List<Ranking>>(
       future: () {Provider.of<ClusterNotifier>(context).getGroups; return widget.group.members.asyncValue();}(),
       builder: (context, snapshot) {
         if (snapshot.hasData) {
           if (snapshot.requireData.isEmpty) return const Icon(Icons.lock);
           return Text(snapshot.requireData.length.toString());
         } else {
           return const Text("---");
         }
       },
     );
   }



  /// joins a public group and closes the current context
  /// Method can only be called when the group is public and user is not a member
  void joinPublicGroup() {
    FetchGroups.joinGroup(widget.group.groupId, null).then((value) {
      Provider.of<ClusterNotifier>(context, listen: false).addGroup(value);
      Provider.of<ClusterNotifier>(context, listen: false).activateGroup(value);
      Navigator.pop(context, {"joined" : true});
    });
  }

  /// joins a private group by getting the invite code from the text field and closes the current context
  /// Method can only be called when the group is private and user is not a member
  void joinPrivateGroup(TextEditingController controller)  {
      FetchGroups.joinGroup(widget.group.groupId, controller.text).then((value) {
        Provider.of<ClusterNotifier>(context, listen: false).addGroup(value);
        Provider.of<ClusterNotifier>(context, listen: false).activateGroup(value);
        Navigator.pop(context, {"joined" : true});
      },onError:  (_) => CustomErrorMessage.message(context: context, message: "Could not join group..."));
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
      await Routing.to(context, EditGroupPage(group: widget.group));
      //trigger rebuild
      setState(() {});
    }
  }



  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


}