import 'dart:typed_data';

import 'package:buff_lisa/8_SelectGroupWidget/select_group_widget_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Providers/cluster_notifier.dart';


class SelectGroupWidgetUI extends StatefulUI<SelectGroupWidget, SelectGroupWidgetState>{

  const SelectGroupWidgetUI({super.key, required state}) : super(state: state);



  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            state.expanded ? expanded(context) : collapsed(context),
            editColumn()
          ],
        )
    );
  }

  Widget editColumn() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
              onTap: state.handleOrderGroup,
              child: state.expanded ? const Icon(Icons.edit,size: 20,) : const SizedBox.shrink(),
          ),
          (state.expanded ? const SizedBox(height: 20,) : const SizedBox.shrink()),
          GestureDetector(
              onTap: state.toggleExpanded,
              child: state.expanded ? const Icon(Icons.arrow_drop_up) : const Icon(Icons.arrow_drop_down)
          )
        ]
    );
  }

  Widget collapsed(BuildContext context) {
    return Container(
          width: MediaQuery.of(context).size.width - 30,
          height: 30,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(bottomLeft:  Radius.circular(10), bottomRight: Radius.circular(10))
          ),
          child: ListView.builder(
            itemCount: Provider.of<ClusterNotifier>(context).getGroups.length,
            itemBuilder: (context, index) => collapsedGroupCard(index),
            scrollDirection: Axis.horizontal,
          )
      );
  }

  Widget expanded(BuildContext context) {
    return Container(
          width: MediaQuery.of(context).size.width - 30,
          height: 80,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(bottomLeft:  Radius.circular(10), bottomRight: Radius.circular(10))
          ),
          child: ListView.builder(
            itemCount: Provider.of<ClusterNotifier>(context).getGroups.length,
            itemBuilder: groupCard,
            scrollDirection: Axis.horizontal,
          )
      );
  }

  Widget collapsedGroupCard(int index) {
    Group group = Provider.of<ClusterNotifier>(state.context, listen: false).getGroups[index];
    Color color = (group.active && state.widget.multiSelector) ? Provider.of<ThemeProvider>(state.context).getCustomTheme.c1 : Colors.grey;
    return Padding(
        padding: const EdgeInsets.all(5),
        child: GestureDetector(
          onTap: () => state.onGroupTab(group),
          child: SizedBox(
              height: 20,
              width: 35*2,
              child: Column(
                children: [
                  Container(
                    color: color,
                    height: 5,
                  ),
                  Text(
                    group.name,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                    softWrap: false,
                  )
                ],
              )
          )
      )
    );
  }

  /// returns the circle avatar of the group and dynamically loads the image from the server
  Widget groupCard(BuildContext context,int index) {
    Group group = Provider.of<ClusterNotifier>(context, listen: false).getGroups[index];
    Group? lastSelected = Provider.of<ClusterNotifier>(context, listen: false).getLastSelected;
    Color color = Colors.grey;
    if ((group.active && state.widget.multiSelector) || (!state.widget.multiSelector && lastSelected != null && group == lastSelected)) {
      color = Provider.of<ThemeProvider>(context).getCustomTheme.c1;
    }
    return Padding(
        padding: const EdgeInsets.all(5),
        child: GestureDetector(
            onTap: () => state.onGroupTab(group),
            child: CircleAvatar(
                radius: 35,
                backgroundColor: color,
                child: FutureBuilder<Uint8List>(
                  future: group.profileImage.asyncValue(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return CircleAvatar(backgroundImage: Image.memory(snapshot.data!).image, radius: 33,);
                    } else {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade700,
                        highlightColor: Colors.grey.shade900,
                        child: const CircleAvatar(radius: 33,)
                      );
                    }
                  },
                ),
            )
        )
    );
  }
}