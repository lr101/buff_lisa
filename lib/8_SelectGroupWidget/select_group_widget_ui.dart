import 'package:buff_lisa/8_SelectGroupWidget/select_group_widget_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/Widgets/custom_round_image.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Files/DTOClasses/pin.dart';
import '../Providers/date_notifier.dart';


class SelectGroupWidgetUI extends StatefulUI<SelectGroupWidget, SelectGroupWidgetState>{

  const SelectGroupWidgetUI({super.key, required state}) : super(state: state);



  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              expanded(context),
              //editColumn()
            ],
          )
      ),
    );
  }

  Widget editColumn() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
              onTap: state.handleOrderGroup,
              child: const SizedBox(
                  height: 50,
                  width: 30,
                  child: Icon(Icons.edit,size: 20,),
                ),
          ),
        ]
    );
  }


  Widget expanded(BuildContext context) {
    double baseHeight = MediaQuery.of(context).size.height * 0.09;
    return Container(
      clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
            border: Border.all(color:Colors.transparent),
            borderRadius: BorderRadius.all(Radius.circular(baseHeight / 2)),
            color: Colors.grey.withOpacity(0.4)
        ),
          width: MediaQuery.of(context).size.width - 10,
          height: baseHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child:Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                  border: Border.all(color:Colors.transparent),
                  borderRadius: BorderRadius.all(Radius.circular(baseHeight / 2)),
                  color:Colors.transparent
              ),
              child: ListView.builder(
              itemCount: Provider.of<ClusterNotifier>(context).getGroups.length,
              itemBuilder: groupCard,
              scrollDirection: Axis.horizontal,
          )))
      );
  }

  /// returns the circle avatar of the group and dynamically loads the image from the server
  Widget groupCard(BuildContext context,int index) {
    double baseHeight =( MediaQuery.of(context).size.height * 0.09) - 15;
    Group group = Provider.of<ClusterNotifier>(context, listen: false).getGroups[index];
    Color color = Colors.grey.withOpacity(0.8);
    Widget num = const SizedBox.shrink();
    if ((group.active)) {
      color = Colors.transparent;
      num = getNumNewPosts(group, context);
    }
    return Padding(
        padding: const EdgeInsets.all(5),
        child: GestureDetector(
            onTap: () => state.onGroupTab(group),
            child: CustomRoundImage(
                  size: baseHeight / 2,
                  clickable: false,
                  imageCallback: group.profileImage.asyncValue,
                  child: Stack(
                    children: [
                    CircleAvatar(
                      radius: baseHeight / 2,
                      backgroundColor: color,
                    ),
                    Align(
                          alignment: Alignment.topRight,
                          child: num
                      ),
                    ],
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
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(snapshot.requireData.toString())
            )
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