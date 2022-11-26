import 'dart:typed_data';

import 'package:buff_lisa/6_Group_Search/my_groups_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Files/DTOClasses/group.dart';
import '../Files/global.dart' as global;
import '../Providers/cluster_notifier.dart';


class MyGroupsUI extends StatefulUI<MyGroupsPage, MyGroupsPageState>{

  const MyGroupsUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
              'My Groups',
              style: TextStyle(color: Colors.white)),
              backgroundColor: global.cThird,
        ),
        backgroundColor: Colors.white,
        body: ListView.separated(
          itemCount: Provider.of<ClusterNotifier>(context).getGroups.length + 1,
          padding: const EdgeInsets.all(8.0),
          separatorBuilder: (BuildContext context, int index) => const Divider(),
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return getCardExploreExistingGroups();
            } else {
              index--;
              return getCardOfGroup(index, context);
            }

          },
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
        onTap: state.handlePressSearchGroup,
        title: const Text(
            "Explore existing groups",
            style: TextStyle(color: global.cPrime)
        ),
        leading: const Icon(Icons.add),
      ),
    );
  }

  /// Builds the Card of the Group of the @index
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
            title: Row(
                children: [
                  FutureBuilder<Uint8List>(
                    future: group.getProfileImage(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return CircleAvatar(backgroundImage: Image.memory(snapshot.data!).image, radius: 20,);
                      } else {
                        return const CircleAvatar(backgroundColor: Colors.grey, radius: 20,);
                      }
                    },
                  ),
                  const SizedBox(width: 20,),
                  Text(group.name)
                ]
            ),
            leading: Text(
              "${index + 1}.",
              style: const TextStyle(color: global.cPrime),
            ),
          ),
        )
    );
  }

}