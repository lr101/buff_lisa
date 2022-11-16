import 'package:buff_lisa/5_Ranking/feed_ui.dart';
import 'package:buff_lisa/6_Group_Search/create_group_logic.dart';
import 'package:buff_lisa/6_Group_Search/search_ui.dart';
import 'package:buff_lisa/Files/restAPI.dart';
import 'package:flutter/material.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';

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

  @override
  bool get wantKeepAlive => true;
}