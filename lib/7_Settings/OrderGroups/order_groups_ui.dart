import 'dart:typed_data';

import 'package:buff_lisa/Files/Widgets/custom_title.dart';
import 'package:flutter/material.dart';

import '../../Files/AbstractClasses/abstract_widget_ui.dart';
import '../../Files/DTOClasses/group.dart';
import 'order_groups_logic.dart';

class OrderGroupUI extends StatefulUI<OrderGroups, OrderGroupsState>{
  const OrderGroupUI({super.key, required super.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomTitle(
              titleBar: CustomTitleBar(
                title: "Sort Group",
                action: CustomAction(
                    action: state.saveOrder,
                    icon: const Icon(Icons.add_task)
                ),
              )
          ),
          Expanded(child:
            ReorderableListView(
              onReorder: state.onReorder,
              children: state.groups.map((item) => getCardOfGroup(item, context)).toList()
            ),
          )
        ],
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
            title: Text(group.name),
            leading:  group.profileImage.customWidget(
                callback: (p0) => CircleAvatar(backgroundImage: Image.memory(p0).image, radius: 20,),
                elseFunc: () => const CircleAvatar(backgroundColor: Colors.grey, radius: 20,),
          ),
          trailing: const Icon(Icons.menu),
        )
    );
  }

}