import 'package:buff_lisa/6_Group_Search/ClickOnExplore/search_logic.dart';
import 'package:buff_lisa/6_Group_Search/ClickOnExplore/search_notifier.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/Widgets/CustomSliverList/custom_easy_title.dart';
import 'package:buff_lisa/Files/Widgets/custom_title.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';


class SearchUI extends StatefulUI<SearchGroupPage, SearchGroupPageState>{

  const SearchUI({super.key, required state}) : super(state: state);



  @override
  Widget build(BuildContext context) {
    return CustomTitle.withoutSlivers(
          title: CustomEasyTitle(
            title: Consumer<SearchNotifier>(builder: (context, value, child) => value.title),
            right: CustomEasyAction(
                child: Consumer<SearchNotifier>(builder: (context, value, child) => value.icon),
                action: () async => Provider.of<SearchNotifier>(context, listen: false).toggle(state.filtered)
            )
          ),
          child: PagedListView<dynamic, Widget>(
            pagingController: state.pagingController,
            builderDelegate: PagedChildBuilderDelegate<Widget>(
              itemBuilder: (context, item, index) => item,
            ),
          ),
    );
  }





}