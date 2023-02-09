import 'dart:typed_data';

import 'package:buff_lisa/6_Group_Search/my_groups_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/Widgets/CustomTitle.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';


class MyGroupsUI extends StatefulUI<MyGroupsPage, MyGroupsPageState>{

  const MyGroupsUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: ListView.builder(
            itemCount: Provider.of<ClusterNotifier>(context).getGroups.length + 2,
            padding: const EdgeInsets.all(8.0),
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return getTitle();
              } else if (index == 1) {
                return getCardExploreExistingGroups();
              } else {
                index -= 2;
                return getCardOfGroup(index, context);
              }
            },
          )
      )
    );
  }

  Widget getTitle() {
    return const CustomTitle(
        title: "My Groups",
        back: false,
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
        onTap: state.handlePressSearchGroup,
        title: const Text("Explore existing groups",),
        leading: const Icon(Icons.add),
      ),
    );
  }

  /// Builds the Card of the Group of the [index]
  /// Shows the profile picture and name
  /// opens a page to show more information of group on single press
  Widget getCardOfGroup(int index, BuildContext context) {
    Group group = Provider.of<ClusterNotifier>(context, listen: false).getGroups[index];
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: GestureDetector(
          onTap: () => state.handlePressGroupCard(group),
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

}