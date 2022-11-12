import 'package:buff_lisa/5_Ranking/ranking_logic.dart';
import 'package:buff_lisa/6_Group_Search/search_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Files/DTOClasses/group.dart';
import '../Files/global.dart' as global;
import '../Providers/cluster_notifier.dart';


class SearchUI extends StatefulUI<SearchGroupPage, SearchGroupPageState>{

  const SearchUI({super.key, required state}) : super(state: state);



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
              'Leaderboard',
              style: TextStyle(color: Colors.white)),
              backgroundColor: global.cThird,
        ),
        backgroundColor: Colors.white,
        body: RefreshIndicator(
            onRefresh: state.pullRefresh,
            child: ListView.separated(
                itemCount: state.groups.length + 1,
                padding: const EdgeInsets.all(8.0),
                separatorBuilder: (BuildContext context, int index) => const Divider(),
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return getCardCreateNewGroup();
                  } else {
                    index--;
                    if (Provider.of<ClusterNotifier>(context, listen: false).getGroups.any((e) => e.groupId == state.groups[index].groupId)) {
                      return getCardOfMemberGroup(index);
                    }
                    return getCardOfOtherGroups(index);
                  }

                },
              )
          )
    );
  }

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

  Widget getCardOfMemberGroup(int index) {

    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        color: Colors.green[200],
        child: ListTile(
          title: Text(
              state.groups[index].name,
              style: const TextStyle(color: global.cPrime)
          ),
          leading: Text(
              "${index + 1}.",
              style: const TextStyle(color: global.cPrime)
          ),
          trailing: const Text(
              "You are a member",
              style: TextStyle(color: global.cPrime)
          ),
        )
    );
  }

  Widget getCardOfOtherGroups(int index) {
    int visibility = state.groups[index].visibility;
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
            title: Text(
            state.groups[index].name,
            style: const TextStyle(color: global.cPrime)),
            leading: Text(
              "${index + 1}.",
              style: const TextStyle(color: global.cPrime),
            ),
            trailing: Text(
                (visibility == 0 ? "public" : "private"),
                style: const TextStyle(color: global.cPrime)
            )
        )
    );
  }

}