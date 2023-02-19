import 'package:buff_lisa/7_Settings/OrderGroups/order_groups_logic.dart';
import 'package:buff_lisa/8_SelectGroupWidget/select_group_widget_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';


class SelectGroupWidget extends StatefulWidget {
  const SelectGroupWidget({super.key, required this.multiSelector, required this.expanded});

  /// parameter for selecting just one or multiple shown groups
  /// true: multiple selection possible
  /// false: single selection
  final bool multiSelector;

  /// flag for initializing expanded or not
  final bool expanded;

  @override
  SelectGroupWidgetState createState() => SelectGroupWidgetState();
}

class SelectGroupWidgetState extends State<SelectGroupWidget> {

  /// flag for saving if top bar is currently expanded or not
  late bool expanded;

  @override
  Widget build(BuildContext context) => SelectGroupWidgetUI(state: this,);

  @override
  void initState() {
    super.initState();
    expanded = widget.expanded;
  }

  void toggleExpanded() {
    setState(() {
      expanded = !expanded;
    });
  }

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

  /// Opens the SearchGroupPage Widget as a new page
  void handleOrderGroup() {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => const OrderGroups()
      ),
    );
  }

}