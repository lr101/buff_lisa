import 'dart:typed_data';

import 'package:buff_lisa/6_Group_Search/search_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../Files/DTOClasses/group.dart';
import '../Files/Other/global.dart' as global;
import '../Files/Widgets/CustomTitle.dart';


class SearchUI extends StatefulUI<SearchGroupPage, SearchGroupPageState>{

  const SearchUI({super.key, required state}) : super(state: state);



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PagedListView<int, Group>(
          pagingController: state.pagingController,
          builderDelegate: PagedChildBuilderDelegate<Group>(
            itemBuilder: (context, item, index) {
              if (index == 0) {
                return getTitle(context);
              } else if (index == 1) {
                return getCardCreateNewGroup();
              } else {
                index -= 2;
                return getCardOfOtherGroups(item, index);
              }
            }
          ),
        )
    );
  }

  Widget getTitle(BuildContext context) {
    return const CustomTitle(
        title: "Search Groups",
        back: true,
      );
    return SizedBox(
      height: 200,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
              Row(
                children: [
                  SizedBox(width: MediaQuery.of(context).size.width - 100, child: state.customSearchBar),
                  IconButton(onPressed: () => state.handleSearch(), icon: state.icon),
                ],
              )
            ],
          ),
          const SizedBox(height: 18,),
          const Text("Search Groups", style: TextStyle(fontSize: 20),)
        ],
      ),
    ) ;
  }

  /// Get Card with button to navigate to create group page
  /// Is always at the first postion of the list
  Widget getCardCreateNewGroup() {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          onTap: state.handlePressNewGroup,
          title: const Text(
              "Create a new group",
              style: TextStyle(color: global.cPrime)
          ),
          leading: const Icon(Icons.add),
          ),
        );
  }

  /// Get Card of a Group
  /// Shows the name, group image, visibility
  Widget getCardOfOtherGroups(Group group, int index) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: GestureDetector(
          onTap: () => state.handleJoinGroupPress(group),
          child: ListTile(
            title: Row(
                children: [
                  FutureBuilder<Uint8List>(
                    future: group.profileImage.asyncValue(),
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
            trailing: (group.visibility != 0 ? const Icon(Icons.lock_outline) : const Icon(Icons.lock_open)),
          ),
        )
    );
  }

}