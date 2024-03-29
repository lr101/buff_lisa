import 'package:buff_lisa/6_Group_Search/ClickOnExplore/ClickOnCreateGroup/create_group_logic.dart';
import 'package:buff_lisa/6_Group_Search/ClickOnExplore/search_logic.dart';
import 'package:buff_lisa/6_Group_Search/my_groups_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/Widgets/CustomSliverList/custom_easy_title.dart';
import 'package:buff_lisa/Files/Widgets/CustomSliverList/custom_sliver_list.dart';
import 'package:buff_lisa/Files/Widgets/custom_title.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:buff_lisa/Providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Files/Routes/routing.dart';


class MyGroupsUI extends StatefulUI<MyGroupsPage, MyGroupsPageState>{

  const MyGroupsUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return CustomTitle.withSliverList(
              title: CustomEasyTitle(
                title: Text("My Groups", style: Provider.of<ThemeNotifier>(context).getTheme.textTheme.titleMedium),
                back: false,
                right: CustomEasyAction(
                  child: PopupMenuButton(
                      icon: const Icon(Icons.add),
                      itemBuilder: (context) {
                        return [
                          const PopupMenuItem<int>(
                              value: 0,
                              child: Text("Search existing groups")
                          ),
                          const PopupMenuItem<int>(
                              value: 1,
                              child: Text("Create a new group")
                          )
                        ];
                      },
                      onSelected:(value){
                        switch (value) {
                          case 0: Routing.to(context, const SearchGroupPage(), true);break;
                          case 1: Routing.to(context, const CreateGroupPage(), true);break;
                        }
                      }
                  ),
                ),
              ),
              sliverList: CustomSliverList(
                pagingController: state.controller,
                initPagedList: () async {
                  state.groups = Provider.of<ClusterNotifier>(context).getGroups;
                  return true;
                },
              ),
            );
  }




}