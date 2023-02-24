import 'package:buff_lisa/6_Group_Search/ClickOnExplore/ClickOnCreateGroup/create_group_logic.dart';
import 'package:buff_lisa/6_Group_Search/ClickOnExplore/search_notifier.dart';
import 'package:buff_lisa/6_Group_Search/ClickOnExplore/search_ui.dart';
import 'package:buff_lisa/6_Group_Search/ClickOnGroup/show_group_logic.dart';
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_groups.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';


class SearchGroupPage extends StatefulWidget {
  const SearchGroupPage({super.key});

  @override
  SearchGroupPageState createState() => SearchGroupPageState();
}

class SearchGroupPageState extends State<SearchGroupPage> {

  /// number of items loaded into every page of page list
  final int _numPages = 15;

  /// controller of page list
  final PagingController<int, Group> pagingController = PagingController(firstPageKey: 0, invisibleItemsThreshold: 1);


  /// List of all group ids that could be shown in page list
  late List<int> groups = [];

  Map<int, Group> loadedGroups = {};


  /// Boolean to track if groups in list are currently filtered in list view
  /// Used to know if reset is needed when deactivating search
  /// true: groups in list are filtered currently
  /// false: groups in list are not filtered currently
  bool filtered = false;

  @override
  late BuildContext context;

  @override
  Widget build(BuildContext context) {
    final state = this;
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: SearchNotifier(pullRefresh: pullRefresh),
          ),
        ],
        builder: (context, child) {
          this.context = context;
          return SearchUI(state: state);
        },
    );
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

  /// Gets group information of ids from index range [pageKey, pageKey + _numPages -1]
  /// Adds the Groups to [pagingController] to be build in page List
  Future<void> _fetchPage(int pageKey) async {
    try {
      List<Group> g = [];
      if (pageKey > 1) {
        int rangeEnd = (pageKey + _numPages - 2 < groups.length ? pageKey + _numPages - 2 : groups.length);
        List<int> sublistOfIds = [];
        for(int groupId in groups.sublist(pageKey - 2, rangeEnd)) {
          Group? group = loadedGroups[groupId];
          if (group != null) {
            g.add(group);
          } else {
            sublistOfIds.add(groupId);
          }
        }
        if (sublistOfIds.isNotEmpty) {
          List<Group> loaded = await FetchGroups.getGroups(sublistOfIds);
          g.addAll(loaded);
          for (Group group in loaded) {
            loadedGroups[group.groupId] = group;
          }
        }
      } else {
        g.add(Group(groupId: 0, name: "", groupAdmin: "", inviteUrl: null, visibility: 0));
      }
      if (g.length < _numPages && pageKey > 1) {
        pagingController.appendLastPage(g);
      } else if (pageKey == 0 || pageKey == 1) {
        pagingController.appendPage(g, pageKey + 1);
      } else {
        pagingController.appendPage(g, pageKey + _numPages);
      }
    } catch (error) {
      pagingController.error();
    }
  }

  /// gets all Group ids that could be shown in page list
  /// [value] is the search term passed to the server to get the corresponding results
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
    Map<String, dynamic>? result = await Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => ShowGroupPage(group: group, myGroup: false)),
    );
    if (result != null && result["joined"] != null && result["joined"] as bool) {
      groups.removeWhere((element) => element == group.groupId);
      pagingController.refresh();
    }
  }

}