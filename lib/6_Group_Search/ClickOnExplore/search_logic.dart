import 'package:buff_lisa/6_Group_Search/ClickOnExplore/ClickOnCreateGroup/create_group_logic.dart';
import 'package:buff_lisa/6_Group_Search/ClickOnExplore/search_notifier.dart';
import 'package:buff_lisa/6_Group_Search/ClickOnExplore/search_ui.dart';
import 'package:buff_lisa/6_Group_Search/ClickOnGroup/show_group_logic.dart';
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/Routes/routing.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_groups.dart';
import 'package:buff_lisa/Files/Widgets/custom_error_message.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../../Files/Widgets/custom_list_tile.dart';


class SearchGroupPage extends StatefulWidget {
  const SearchGroupPage({super.key});

  @override
  SearchGroupPageState createState() => SearchGroupPageState();
}

class SearchGroupPageState extends State<SearchGroupPage> {

  /// number of items loaded into every page of page list
  final int _numPages = 15;

  /// controller of page list
  final PagingController<dynamic, Widget> pagingController = PagingController(firstPageKey: 0, invisibleItemsThreshold: 1);


  /// List of all group ids that could be shown in page list
  late List<int> groups = [];

  /// Boolean to track if groups in list are currently filtered in list view
  /// Used to know if reset is needed when deactivating search
  /// true: groups in list are filtered currently
  /// false: groups in list are not filtered currently
  bool filtered = false;

  bool searching = false;

  @override
  late BuildContext context;

  @override
  Widget build(BuildContext context) {
    final state = this;
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SearchNotifier(pullRefresh: pullRefresh, context: context),),
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
    if (searching) {
      pagingController.appendLastPage([const Center(child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator()),)]);
      return;
    }
      if (pageKey + 15 < groups.length) {
        List<Widget> widgets = [];
        int i = pageKey;
        for (; pageKey < i + 15; pageKey++) {
          widgets.add(await getCardOfOtherGroups(pageKey));
        }
        pagingController.appendPage(widgets, pageKey);
      } else {
        List<Widget> widgets = [];
        for (; pageKey < groups.length; pageKey++) {
          widgets.add(await getCardOfOtherGroups(pageKey));
        }
        pagingController.appendLastPage(widgets);
      }
  }

  /// gets all Group ids that could be shown in page list
  /// [value] is the search term passed to the server to get the corresponding results
  Future<void> pullRefresh(String? value) async {
    searching = true;
    pagingController.refresh();
    value = (value == null || value.isEmpty ? null : value);
    groups = await FetchGroups.fetchAllGroupsWithoutUserGroupsIds(value);
    filtered = value != null;
    searching = false;
    pagingController.refresh();
  }


  /// opens the CreateGroupPage Widget when the create group page button is pressed
  void handlePressNewGroup() {
    Routing.to(context,  const CreateGroupPage());
  }

/// Get Card of a Group
/// Shows the name, group image, visibility
Future<Widget> getCardOfOtherGroups(int index) async {
    return FutureBuilder<Group>(
        future:  getGroup(index),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return CustomListTile.fromGroup(snapshot.requireData, () => handleJoinGroupPress(snapshot.requireData));
          } else {
            return CustomListTile.fromGroup(global.basicGroup, () {CustomErrorMessage.message(context: context, message: "loading...");});
          }
        },
    );
}

Future<Group> getGroup(int index) async {
  Group group;
  try {
    group = Provider.of<ClusterNotifier>(context, listen: false).otherGroups.firstWhere((element) => element.groupId == groups[index]);
  } catch(_) {
    group = await FetchGroups.getGroup(groups[index], false);
    if (!mounted) return global.basicGroup;
    Provider.of<ClusterNotifier>(context,listen: false).addOtherGroup(group);
  }
  return group;
}

  /// opens the ShowGroupPage Widget when a group card is pressed and wait for the result
  /// If the group was joined the group card is removed from the list of join able groups
  Future<void> handleJoinGroupPress(Group group) async {
    Map<String, dynamic>? result = await Routing.to(context, ShowGroupPage(group: group, myGroup: false));
    if (result != null && result["joined"] != null && result["joined"] as bool) {
      groups.removeWhere((element) => element == group.groupId);
      pagingController.refresh();
    }
  }

}