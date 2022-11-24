import 'package:buff_lisa/5_Ranking/feed_ui.dart';
import 'package:buff_lisa/6_Group_Search/create_group_logic.dart';
import 'package:buff_lisa/6_Group_Search/search_ui.dart';
import 'package:buff_lisa/6_Group_Search/show_group_logic.dart';
import 'package:buff_lisa/Files/fetch_groups.dart';
import 'package:buff_lisa/Files/restAPI.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:flutter/material.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
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
  late List<int> groups = [];
  final int _numPages = 15;
  final PagingController<int, Group> pagingController = PagingController(firstPageKey: 0, invisibleItemsThreshold: 1);
  Icon icon = const Icon(Icons.search);
  Widget customSearchBar = const Text('Explore Groups');
  TextEditingController textController = TextEditingController();
  bool filtered = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SearchUI(state: this);
  }

  @override
  void initState() {
    pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    pullRefresh(null);
    super.initState();
  }

  Future<void> handleSearch() async {
    setState(() {
      if (icon.icon == Icons.search) {
        icon = const Icon(Icons.cancel);
        customSearchBar = ListTile(
          leading: IconButton(
            onPressed: () => pullRefresh(textController.text),
            icon: const Icon(
              Icons.search,
              color: Colors.white,
              size: 28,
            )
          ),
          title: TextField(
            controller: textController,
            onSubmitted: (value) => pullRefresh(value),
            decoration: const InputDecoration(
              hintText: 'type a group name...',
              hintStyle: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
              border: InputBorder.none,
            ),
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        );
      } else {
        icon = const Icon(Icons.search);
        customSearchBar = const Text('Explore Groups');
        if (filtered) pullRefresh(null);
        textController.clear();
      }
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      List<Group> g = [];
      if (pageKey != 0) {
        int rangeEnd = (pageKey + _numPages - 1 < groups.length ? pageKey + _numPages - 1 : groups.length);
        g = await FetchGroups.getGroups(groups.sublist(pageKey - 1, rangeEnd));
      } else {
        g.add(Group(groupId: 0, name: "", groupAdmin: "", inviteUrl: null, visibility: 0));
      }
      if (g.length < _numPages && pageKey != 0) {
        pagingController.appendLastPage(g);
      } else if (pageKey == 0) {
        pagingController.appendPage(g, pageKey + 1);
      } else {
        pagingController.appendPage(g, pageKey + _numPages);
      }
    } catch (error) {
      pagingController.error();
    }
  }

  /// gets the ranking list from the server and replaces the ranking list in widget
  Future<void> pullRefresh(String? value) async {
    value = (value == null || value.isEmpty ? null : value);
    groups = await FetchGroups.fetchAllGroupsWithoutUserGroupsIds(value);
    filtered = value != null;
    pagingController.refresh();
  }

  void handlePressNewGroup() {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => const CreateGroupPage()
      ),
    );
  }

  Future<void> handleJoinGroupPress(Group group) async {
    Map<String, dynamic> result = await Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => ShowGroupPage(group: group, myGroup: false)),
    );
    if (result["joined"] != null && result["joined"] as bool) {
      groups.removeWhere((element) => element == group.groupId);
      pagingController.refresh();
    }
  }



  @override
  bool get wantKeepAlive => true;
}