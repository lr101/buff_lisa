import 'package:buff_lisa/5_Ranking/feed_ui.dart';
import 'package:buff_lisa/6_Group_Search/create_group_logic.dart';
import 'package:buff_lisa/6_Group_Search/join_group_ui.dart';
import 'package:buff_lisa/6_Group_Search/my_groups_ui.dart';
import 'package:buff_lisa/6_Group_Search/search_logic.dart';
import 'package:buff_lisa/6_Group_Search/search_ui.dart';
import 'package:buff_lisa/6_Group_Search/show_group_ui.dart';
import 'package:buff_lisa/Files/restAPI.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:flutter/material.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:provider/provider.dart';
import '../Files/DTOClasses/group.dart';
import '../Files/DTOClasses/ranking.dart';
import 'create_group_ui.dart';


class MyGroupsPage extends StatefulWidget {
  const MyGroupsPage({super.key});

  @override
  MyGroupsPageState createState() => MyGroupsPageState();
}

class MyGroupsPageState extends State<MyGroupsPage> with AutomaticKeepAliveClientMixin<MyGroupsPage>{

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MyGroupsUI(state: this);
  }

  void handlePressNewGroup() {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => const SearchGroupPage()
      ),
    );
  }

  Future<void> handleJoinGroupPress(Group group) async {
    final size = MediaQuery.of(context).size;
    showDialog(
        context: context,
        builder: (BuildContext alertContext) => ShowGroupUI.build(alertContext, size, group)
    );
  }



  @override
  bool get wantKeepAlive => true;
}