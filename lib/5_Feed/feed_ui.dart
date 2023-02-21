import 'package:buff_lisa/5_Feed/feed_logic.dart';
import 'package:buff_lisa/8_SelectGroupWidget/select_group_widget_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class FeedUI extends StatefulUI<FeedPage, FeedPageState>{

  const FeedUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    state.init();
    return Scaffold(appBar: null,
        body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                  child: RefreshIndicator(
                      onRefresh: () async => state.pullRefresh(refresh: true),
                      child:PagedListView<int, Widget> (
                      pagingController: state.pagingController,
                      builderDelegate: PagedChildBuilderDelegate<Widget>(
                        animateTransitions: false,
                        itemBuilder: (context, item, index)  => item,
                      ),
                    )
                  )
              )
            ]
        )
    );
  }




}