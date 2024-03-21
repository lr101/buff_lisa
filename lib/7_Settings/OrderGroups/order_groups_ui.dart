import 'package:buff_lisa/Files/Widgets/custom_title.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Files/AbstractClasses/abstract_widget_ui.dart';
import '../../Files/DTOClasses/group.dart';
import '../../Files/Widgets/CustomSliverList/custom_easy_title.dart';
import '../../Files/Widgets/custom_round_image.dart';
import '../../Providers/theme_provider.dart';
import 'order_groups_logic.dart';

class OrderGroupUI extends StatefulUI<OrderGroups, OrderGroupsState>{
  const OrderGroupUI({super.key, required super.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomTitle(
          title: CustomEasyTitle(
            title: Text("Sort Group", style: Provider.of<ThemeNotifier>(context).getTheme.textTheme.titleMedium),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text("Order groups by long pressing to drag and drop", style: TextStyle(fontStyle: FontStyle.italic),),
              Expanded(
                child: ReorderableListView(
                    onReorder: state.onReorder,
                    children: state.groups.map((item) => getCardOfGroup(item, context)).toList()
                  ),
                )
              ]
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async => state.saveOrder(),
        child: const Icon(Icons.check),
      ),
    );
  }

  /// Builds the Card of the Group of the [index]
  /// Shows the profile picture and name
  /// opens a page to show more information of group on single press
  Widget getCardOfGroup(Group group, BuildContext context) {
    return Card(
      key: Key(group.groupId.toString()),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
            title: Text(group.name, style: Provider.of<ThemeNotifier>(context).getTheme.textTheme.titleMedium),
            leading:  CustomRoundImage(
              size: 20,
              imageCallback: group.profileImage.asyncValue,
            ),
          trailing: const Icon(Icons.menu),
        )
    );
  }

}