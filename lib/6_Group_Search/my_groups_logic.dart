import 'dart:typed_data';

import 'package:buff_lisa/6_Group_Search/ClickOnExplore/search_logic.dart';
import 'package:buff_lisa/6_Group_Search/ClickOnGroup/show_group_logic.dart';
import 'package:buff_lisa/6_Group_Search/my_groups_ui.dart';
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

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
      if (pageKey == 0) {
        controller.appendPage([getCardExploreExistingGroups()], pageKey + 1);
      } else {
        if (pageKey + 50 < groups.length + 1) {
          controller.appendPage(List.generate(50, (index) => getCardOfGroup(index - 1 + pageKey as int)), pageKey + 50);
        } else {
          controller.appendLastPage(List.generate(groups.length + 1 - pageKey as int, (index) => getCardOfGroup(index - 1 + pageKey as int)));
        }
      }
    });

  }


  /// Builds the Card of the Group of the [index]
  /// Shows the profile picture and name
  /// opens a page to show more information of group on single press
  Widget getCardOfGroup(int index) {
    Group group = Provider.of<ClusterNotifier>(context, listen: false).getGroups[index];
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: GestureDetector(
          onTap: () => handlePressGroupCard(group),
          child: ListTile(
            title: Text(group.name),
            leading:FutureBuilder<Uint8List>(
              future: group.profileImage.asyncValue(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return CircleAvatar(backgroundImage: Image.memory(snapshot.data!).image, radius: 20,);
                } else {
                  return const CircleAvatar(backgroundColor: Colors.grey, radius: 20,);
                }
              },
            ),
          ),
        )
    );
  }

  /// Builds the Card for showing the button that on press navigates to the SearchGroupPage Widget
  /// Always the first item in List
  Widget getCardExploreExistingGroups() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: ListTile(
        onTap: handlePressSearchGroup,
        title: const Text("Explore existing groups",),
        leading: const Icon(Icons.add),
      ),
    );
  }

  /// Opens the SearchGroupPage Widget as a new page
  void handlePressSearchGroup() {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => const SearchGroupPage()
      ),
    );
  }

  /// Opens the ShowGroupPage Widget as a new page
  Future<void> handlePressGroupCard(Group group) async {
    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => ShowGroupPage(group: group, myGroup: true)
        )
    );
  }

  /// keep Widget alive when changing tabs in navbar
  @override
  bool get wantKeepAlive => true;
}