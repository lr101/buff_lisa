import 'dart:typed_data';

import 'package:buff_lisa/5_Ranking/feed_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import '../Files/DTOClasses/group.dart';
import '../Files/DTOClasses/pin.dart';
import '../Files/global.dart' as global;
import '../SelectGroupWidget/select_group_widget_logic.dart';
import 'feed_card_logic.dart';


class FeedUI extends StatefulUI<FeedPage, FeedPageState>{

  const FeedUI({super.key, required state}) : super(state: state);



  @override
  Widget build(BuildContext context) {
    state.initSortedPins();
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SelectGroupWidget(multiSelector: true),
              Expanded(
                  child: PagedListView<int, Widget> (
                    pagingController: state.pagingController,
                    builderDelegate: PagedChildBuilderDelegate<Widget>(
                      itemBuilder: (context, item, index)  => item,
                    ),
                  )
              )
            ]
        )
    );
  }




}