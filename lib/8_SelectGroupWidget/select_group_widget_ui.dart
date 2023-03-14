import 'dart:typed_data';

import 'package:buff_lisa/8_SelectGroupWidget/select_group_widget_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/Widgets/custom_if_else.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:buff_lisa/Providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../Files/DTOClasses/pin.dart';
import '../Providers/date_notifier.dart';


class SelectGroupWidgetUI extends StatefulUI<SelectGroupWidget, SelectGroupWidgetState>{

  const SelectGroupWidgetUI({super.key, required state}) : super(state: state);



  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIfElse(
                ifWidget: expanded(context),
                elseWidget: collapsed(context),
                ifTest: () => state.expanded
            ),
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
              child: CustomIfElse(
                ifTest: () => state.expanded,
                ifWidget: const SizedBox(
                  height: 50,
                  width: 30,
                  child: Icon(Icons.edit,size: 20,),
                ),
                elseWidget: const SizedBox.shrink(),
              )
          ),
          GestureDetector(
              onTap: state.toggleExpanded,
              behavior: HitTestBehavior.translucent,
              child: SizedBox(
                height: 30,
                width: 30,
                child: CustomIfElse(
                  ifTest: () => state.expanded,
                  ifWidget: const Icon(Icons.arrow_drop_up),
                  elseWidget: const Icon(Icons.arrow_drop_down),
                ),
            )
          )
        ]
    );
  }

  Widget collapsed(BuildContext context) {
    return SizedBox(
          width: MediaQuery.of(context).size.width - 30,
          height: 30,
          child: ListView.builder(
            itemCount: Provider.of<ClusterNotifier>(context).getGroups.length,
            itemBuilder: (context, index) => collapsedGroupCard(index),
            scrollDirection: Axis.horizontal,
          )
      );
  }

  Widget expanded(BuildContext context) {
    return SizedBox(
          width: MediaQuery.of(context).size.width - 30,
          height: 80,
          child: ListView.builder(
            itemCount: Provider.of<ClusterNotifier>(context).getGroups.length,
            itemBuilder: groupCard,
            scrollDirection: Axis.horizontal,
          )
      );
  }

  Widget collapsedGroupCard(int index) {
    Group group = Provider.of<ClusterNotifier>(state.context, listen: false).getGroups[index];
    Color color = (group.active) ? Provider.of<ThemeNotifier>(state.context).getCustomTheme.c1 : Colors.grey;
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
    Color color = Colors.grey;
    Widget num = const SizedBox.shrink();
    if ((group.active)) {
      color = Provider.of<ThemeNotifier>(context).getCustomTheme.c1;
      num = getNumNewPosts(group, context);
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
                      return CircleAvatar(
                        backgroundImage: Image.memory(snapshot.data!).image,
                        radius: 33,
                        child: Stack(
                        children: [
                            Align(
                              alignment: Alignment.topRight,
                                child: num
                            ),
                          ],
                        )
                      );
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

Widget getNumNewPosts(Group group, BuildContext context) {
  return FutureBuilder<int>(
    future: getNum(group, context),
    builder: (context, snapshot) {
      if (snapshot.hasData && snapshot.requireData > 0) {
        return CircleAvatar(
            radius: 13,
            backgroundColor: Colors.grey,
            child: Text(snapshot.requireData.toString())
        );
      } else {
        return const SizedBox.shrink();
      }
    },
  );

}

Future<int> getNum(Group group, BuildContext context) async {
  DateTime? date = Provider.of<DateNotifier>(context).getDate();
  Set<Pin> pins = await group.pins.asyncValue();
  if (date == null) {
    return pins.length;
  } else {
    int num = 0;
    for (Pin pin in pins) {
      if (pin.creationDate.isAfter(date)) num++;
    }
    return num;
  }
}