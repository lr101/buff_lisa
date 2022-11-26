import 'package:buff_lisa/5_Ranking/feed_logic.dart';
import 'package:buff_lisa/8_SelectGroupWidget/select_group_widget_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

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