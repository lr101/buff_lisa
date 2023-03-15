import 'dart:typed_data';

import 'package:buff_lisa/6_Group_Search/my_groups_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/Widgets/CustomSliverList/custom_easy_title.dart';
import 'package:buff_lisa/Files/Widgets/CustomSliverList/custom_sliver_list.dart';
import 'package:buff_lisa/Files/Widgets/custom_title.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class MyGroupsUI extends StatefulUI<MyGroupsPage, MyGroupsPageState>{

  const MyGroupsUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: null,
            body: CustomSliverList(
                title: const CustomEasyTitle(title: "My Groups", back: false),
                appBar: const SizedBox.shrink(),
                appBarHeight: 0,
                pagingController: state.controller,
                initPagedList: () async {
                  state.groups = Provider.of<ClusterNotifier>(context).getGroups;
                  return true;
                },
            ),
          )
      );
  }




}