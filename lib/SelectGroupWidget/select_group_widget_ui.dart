import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/SelectGroupWidget/select_group_widget_logic.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Files/DTOClasses/group.dart';
import '../Files/global.dart' as global;
import '../Providers/cluster_notifier.dart';


class SelectGroupWidgetUI extends StatefulUI<SelectGroupWidget, SelectGroupWidgetState>{

  const SelectGroupWidgetUI({super.key, required state}) : super(state: state);



  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: MediaQuery.of(context).viewPadding.top + 80,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Container(
                height: MediaQuery.of(context).viewPadding.top,
                width: double.infinity,
                color: global.cThird
            ),
            Container(
                width: double.infinity,
                height: 80,
                decoration: const BoxDecoration(
                    color: global.cThird,
                    borderRadius: BorderRadius.only(bottomLeft:  Radius.circular(10), bottomRight: Radius.circular(10))
                ),
                child: ListView.builder(
                  itemCount: Provider.of<ClusterNotifier>(context).getGroups.length,
                  itemBuilder: groupCard,
                  scrollDirection: Axis.horizontal,
                )
            )
          ],
        )
    );
  }


  Widget groupCard(BuildContext context,int index) {
    Group group = Provider.of<ClusterNotifier>(context, listen: false).getGroups[index];
    Group? lastSelected = Provider.of<ClusterNotifier>(context, listen: false).getLastSelected;
    Color color = Colors.grey;
    if ((group.active && state.widget.multiSelector) || (!state.widget.multiSelector && lastSelected != null && group == lastSelected)) {
      color = Colors.red;
    }
    return Padding(
        padding: const EdgeInsets.all(5),
        child: GestureDetector(
            onTap: () => state.onGroupTab(group),
            child: CircleAvatar(
                radius: 35,
                backgroundColor: color,
                child: CircleAvatar(
                  backgroundImage: Image.memory(group.profileImage).image,
                  radius: 33,
                )
            )
        )
    );
  }
}