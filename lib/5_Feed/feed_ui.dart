import 'package:buff_lisa/5_Feed/feed_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/Widgets/CustomSliverList/custom_sliver_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/cluster_notifier.dart';

class FeedUI extends StatefulUI<FeedPage, FeedPageState> {
  const FeedUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: RefreshIndicator(
          onRefresh: () async {await state.pullRefresh(refresh: true, state.groups); state.pagingController.refresh();},
          child: CustomSliverList(
            nestedScrollView: false,
            pagingController: state.pagingController,
            initPagedList: () async => await state.pullRefresh(
                refresh: false,
                Provider.of<ClusterNotifier>(context).getActiveGroups.toSet()),
          )),
    );
  }
}
