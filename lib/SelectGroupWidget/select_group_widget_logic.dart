import 'package:buff_lisa/5_Ranking/feed_ui.dart';
import 'package:buff_lisa/Files/restAPI.dart';
import 'package:buff_lisa/SelectGroupWidget/select_group_widget_ui.dart';
import 'package:flutter/material.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:provider/provider.dart';

import '../Files/DTOClasses/group.dart';
import '../Files/DTOClasses/ranking.dart';
import '../Providers/cluster_notifier.dart';


class SelectGroupWidget extends StatefulWidget {
  const SelectGroupWidget({super.key, required this.multiSelector});

  final bool multiSelector;

  @override
  SelectGroupWidgetState createState() => SelectGroupWidgetState();
}

class SelectGroupWidgetState extends State<SelectGroupWidget> {

  @override
  Widget build(BuildContext context) => SelectGroupWidgetUI(state: this,);


  void onGroupTab(Group group) {
    if (widget.multiSelector) {
      if (group.active) {
        Provider.of<ClusterNotifier>(context, listen:false).deactivateGroup(group);
      } else {
        Provider.of<ClusterNotifier>(context, listen:false).activateGroup(group);
      }
    } else {
      Provider.of<ClusterNotifier>(context, listen:false).setLastSelected(group);
    }

  }

}