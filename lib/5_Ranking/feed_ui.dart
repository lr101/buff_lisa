import 'package:buff_lisa/5_Ranking/feed_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Files/DTOClasses/group.dart';
import '../Files/global.dart' as global;
import '../Providers/feed_notifier.dart';
import '../SelectGroupWidget/select_group_widget_logic.dart';
import 'feed_card_logic.dart';


class FeedUI extends StatefulUI<FeedPage, FeedPageState>{

  const FeedUI({super.key, required state}) : super(state: state);



  @override
  Widget build(BuildContext context) {
    state.init(context);
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SelectGroupWidget(multiSelector: true),
              Expanded(
                  child: ListView.separated(
                    itemCount: Provider.of<FeedNotifier>(context).shownPins.length,
                    controller: state.controller,
                    padding: const EdgeInsets.all(8.0),
                    separatorBuilder: (BuildContext context, int index) => const Divider(),
                    itemBuilder: (context, index) => FeedCard(pin: Provider.of<FeedNotifier>(context, listen: false).shownPins[index]),
                  )
              )
            ]
        )
    );
  }




}