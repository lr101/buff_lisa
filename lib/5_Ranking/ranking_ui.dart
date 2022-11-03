import 'package:buff_lisa/5_Ranking/ranking_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:flutter/material.dart';
import '../Files/global.dart' as global;


class RankingUI extends StatefulUI<RankingPage, RankingPageState>{

  const RankingUI({super.key, required state}) : super(state: state);



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
                itemCount: state.rankings.length,
                padding: const EdgeInsets.all(8.0),
                separatorBuilder: (BuildContext context, int index) => const Divider(),
                itemBuilder: (BuildContext context, int index) {
                  if (state.rankings[index].username == global.username) {
                    return getCardOfUser(index);
                  }
                  return getCardOfOtherUsers(index);
                },
              )
          )
    );
  }

  Widget getCardOfUser(int index) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        color: Colors.green[200],
        child: ListTile(
          title: Text(
              state.rankings[index].username,
              style: const TextStyle(color: global.cPrime)
          ),
          leading: Text(
              "${index + 1}.",
              style: const TextStyle(color: global.cPrime)
          ),
          trailing: Text(
              "${state.rankings[index].points} points",
              style: const TextStyle(color: global.cPrime)
          ),
        )
    );
  }

  Widget getCardOfOtherUsers(int index) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
            title: Text(
            state.rankings[index].username,
            style: const TextStyle(color: global.cPrime)),
            leading: Text(
              "${index + 1}.",
              style: const TextStyle(color: global.cPrime),
            ),
            trailing: Text(
                "${state.rankings[index].points} points",
                style: const TextStyle(color: global.cPrime)
            )
        )
    );
  }

}