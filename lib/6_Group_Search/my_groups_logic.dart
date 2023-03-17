import 'dart:typed_data';

import 'package:buff_lisa/6_Group_Search/ClickOnExplore/ClickOnCreateGroup/create_group_logic.dart';
import 'package:buff_lisa/6_Group_Search/ClickOnExplore/search_logic.dart';
import 'package:buff_lisa/6_Group_Search/ClickOnGroup/show_group_logic.dart';
import 'package:buff_lisa/6_Group_Search/my_groups_ui.dart';
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/Widgets/custom_list_tile.dart';
import 'package:buff_lisa/Files/Widgets/custom_round_image.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../Files/Routes/routing.dart';
import '../Providers/cluster_notifier.dart';


class MyGroupsPage extends StatefulWidget {
  const MyGroupsPage({super.key});

  @override
  MyGroupsPageState createState() => MyGroupsPageState();
}

class MyGroupsPageState extends State<MyGroupsPage> with AutomaticKeepAliveClientMixin<MyGroupsPage>{


  PagingController<dynamic, Widget> controller = PagingController(firstPageKey: 0, invisibleItemsThreshold: 50);

  List<Group> groups = [];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MyGroupsUI(state: this);
  }

  @override
  void initState() {
    super.initState();
    controller.addPageRequestListener((pageKey) async {
        if (pageKey + 50 < groups.length) {
          controller.appendPage(List.generate(50, (index) => getCardOfGroup(index + pageKey as int)), pageKey + 50);
        } else {
          controller.appendLastPage(List.generate(groups.length - pageKey as int, (index) => getCardOfGroup(index + pageKey as int)));
        }
    });

  }


  /// Builds the Card of the Group of the [index]
  /// Shows the profile picture and name
  /// opens a page to show more information of group on single press
  Widget getCardOfGroup(int index) {
    Group group = Provider.of<ClusterNotifier>(context, listen: false).getGroups[index];
    return CustomListTile.fromGroup(group, () => handlePressGroupCard(group));
  }

  /// Opens the SearchGroupPage Widget as a new page
  void handlePressSearchGroup() {
    Routing.to(context,  const SearchGroupPage());
  }

  /// Opens the SearchGroupPage Widget as a new page
  void handlePressCreateGroup() {
    Routing.to(context,  const CreateGroupPage());
  }

  /// Opens the ShowGroupPage Widget as a new page
  Future<void> handlePressGroupCard(Group group) async {
    Routing.to(context,  ShowGroupPage(group: group, myGroup: true));
  }

  /// keep Widget alive when changing tabs in navbar
  @override
  bool get wantKeepAlive => true;
}