import 'package:buff_lisa/6_Group_Search/create_group_logic.dart';
import 'package:buff_lisa/6_Group_Search/search_ui.dart';
import 'package:buff_lisa/6_Group_Search/show_group_logic.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_groups.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../Files/DTOClasses/group.dart';


class SearchGroupPage extends StatefulWidget {
  const SearchGroupPage({super.key});

  @override
  SearchGroupPageState createState() => SearchGroupPageState();
}

class SearchGroupPageState extends State<SearchGroupPage> with AutomaticKeepAliveClientMixin<SearchGroupPage>{

  /// List of all group ids that could be shown in page list
  late List<int> groups = [];

  /// number of items loaded into every page of page list
  final int _numPages = 15;

  /// controller of page list
  final PagingController<int, Group> pagingController = PagingController(firstPageKey: 0, invisibleItemsThreshold: 1);

  /// icon shown in top right of app bar
  /// shows search icon if search is not active
  /// shows exit icon if search is active
  Icon icon = const Icon(Icons.search);

  /// Widget shown in center of app bar
  /// shows title if search is not active
  /// shows text input of search if search is active
  Widget customSearchBar = const Text('Explore Groups');

  /// textController of search input field
  TextEditingController textController = TextEditingController();

  /// Boolean to track if groups in list are currently filtered in list view
  /// Used to know if reset is needed when deactivating search
  /// true: groups in list are filtered currently
  /// false: groups in list are not filtered currently
  bool filtered = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SearchUI(state: this);
  }

  /// add page list scroll listener and its callback function
  @override
  void initState() {
    pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    pullRefresh(null);
    super.initState();
  }

  /// called when search button is clicked
  /// open or removes search textfield in app bar
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

  /// Gets group information of ids from index range [pageKey, pageKey + _numPages -1]
  /// Adds the Groups to @pagingController to be build in page List
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

  /// gets all Group ids that could be shown in page list
  /// @value is the search term passed to the server to get the corresponding results
  Future<void> pullRefresh(String? value) async {
    value = (value == null || value.isEmpty ? null : value);
    groups = await FetchGroups.fetchAllGroupsWithoutUserGroupsIds(value);
    filtered = value != null;
    pagingController.refresh();
  }

  /// opens the CreateGroupPage Widget when the create group page button is pressed
  void handlePressNewGroup() {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => const CreateGroupPage()
      ),
    );
  }

  /// opens the ShowGroupPage Widget when a group card is pressed and wait for the result
  /// If the group was joined the group card is removed from the list of join able groups
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