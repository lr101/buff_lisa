import 'package:buff_lisa/7_Settings/OrderGroups/order_groups_logic.dart';
import 'package:buff_lisa/8_SelectGroupWidget/select_group_widget_ui.dart';
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Files/Routes/routing.dart';


class SelectGroupWidget extends StatefulWidget {
  const SelectGroupWidget({super.key});
  @override
  SelectGroupWidgetState createState() => SelectGroupWidgetState();
}

class SelectGroupWidgetState extends State<SelectGroupWidget> with AutomaticKeepAliveClientMixin<SelectGroupWidget> {

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SelectGroupWidgetUI(state: this,);
  }


  /// handles group press
  /// [multiSelector] true: activates or deactivates group and saves it in ClusterNotifier
  /// [multiSelector] false: set last selected group
  void onGroupTab(Group group) {
    if (group.active) {
      Provider.of<ClusterNotifier>(context, listen:false).deactivateGroup(group);
    } else {
      Provider.of<ClusterNotifier>(context, listen:false).activateGroup(group);
    }
  }

  /// Opens the SearchGroupPage Widget as a new page
  void handleOrderGroup() {
    Routing.to(context,  const OrderGroups());
  }

  @override
  bool get wantKeepAlive => true;

}