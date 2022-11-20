import 'package:buff_lisa/5_Ranking/feed_ui.dart';
import 'package:buff_lisa/6_Group_Search/create_group_logic.dart';
import 'package:buff_lisa/6_Group_Search/join_group_ui.dart';
import 'package:buff_lisa/6_Group_Search/search_ui.dart';
import 'package:buff_lisa/Files/restAPI.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:flutter/material.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:provider/provider.dart';
import '../Files/DTOClasses/group.dart';
import '../Files/DTOClasses/ranking.dart';
import 'create_group_ui.dart';


class SearchGroupPage extends StatefulWidget {
  const SearchGroupPage({super.key});

  @override
  SearchGroupPageState createState() => SearchGroupPageState();
}

class SearchGroupPageState extends State<SearchGroupPage> with AutomaticKeepAliveClientMixin<SearchGroupPage>{
  late List<Group> groups = [];

  /// loads ranking data on initialization of page
  @override
  void initState() {
    pullRefresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SearchUI(state: this);
  }

  /// gets the ranking list from the server and replaces the ranking list in widget
  Future<List<Group>> pullRefresh() async {
    List<Group> reloadedGroups = await RestAPI.fetchAllGroups();
    if (!mounted) return [];
    List<Group> userGroups = Provider.of<ClusterNotifier>(context, listen: false).getGroups;
    reloadedGroups.removeWhere((g1) => userGroups.any((g2) => g1.groupId == g2.groupId));
    reloadedGroups.sort((a,b) => a.name.compareTo(b.name));
    setState(() {
      groups = reloadedGroups;
    });
    return reloadedGroups;
  }

  void handlePressNewGroup() {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => const CreateGroupPage()
      ),
    );
  }

  Future<void> handleJoinGroupPress(Group group) async {
    final size = MediaQuery.of(context).size;
    showDialog(
        context: context,
        builder: (BuildContext alertContext) => JoinGroupUI.build(alertContext, size, group)
    );
  }



  @override
  bool get wantKeepAlive => true;
}