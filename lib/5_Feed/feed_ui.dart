import 'package:buff_lisa/5_Feed/feed_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/Widgets/CustomSliverList/custom_sliver_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Files/Themes/custom_theme.dart';
import '../Providers/cluster_notifier.dart';
import '../Providers/theme_provider.dart';

class FeedUI extends StatefulUI<FeedPage, FeedPageState> {
  const FeedUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.09 + 10,
        centerTitle: true,
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0.0,
        backgroundColor: Color.alphaBlend(CustomTheme.grey, Provider.of<ThemeNotifier>(context).getTheme.canvasColor),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: RefreshIndicator(
          onRefresh: () async {await state.pullRefresh(refresh: true, state.groups); state.pagingController.refresh();},
          child: CustomSliverList(
            nestedScrollView: false,
            pagingController: state.pagingController,
            initPagedList: () async => await state.pullRefresh(
                refresh: false,
                Provider.of<ClusterNotifier>(context).getActiveGroups.toSet()),
          ))),
    );
  }
}
