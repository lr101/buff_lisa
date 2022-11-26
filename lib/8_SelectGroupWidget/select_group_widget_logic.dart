import 'package:buff_lisa/8_SelectGroupWidget/select_group_widget_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Files/DTOClasses/group.dart';
import '../Providers/cluster_notifier.dart';


class SelectGroupWidget extends StatefulWidget {
  const SelectGroupWidget({super.key, required this.multiSelector});

  /// parameter for selecting just one or multiple shown groups
  /// true: multiple selection possible
  /// false: single selection
  final bool multiSelector;

  @override
  SelectGroupWidgetState createState() => SelectGroupWidgetState();
}

class SelectGroupWidgetState extends State<SelectGroupWidget> {

  @override
  Widget build(BuildContext context) => SelectGroupWidgetUI(state: this,);


  /// handles group press
  /// [multiSelector] true: activates or deactivates group and saves it in ClusterNotifier
  /// [multiSelector] false: set last selected group
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