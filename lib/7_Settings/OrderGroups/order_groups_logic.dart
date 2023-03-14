import 'package:buff_lisa/7_Settings/OrderGroups/order_groups_ui.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../Files/DTOClasses/group.dart';
import '../../Files/Other/global.dart' as global;

class OrderGroups extends StatefulWidget {
  const OrderGroups({super.key});

  @override
  OrderGroupsState createState() => OrderGroupsState();
}

class OrderGroupsState extends State<OrderGroups> {
  @override
  Widget build(BuildContext context) => OrderGroupUI(state: this);

  /// All groups that are available to be reordered.
  List<Group> groups = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        groups = Provider.of<ClusterNotifier>(context, listen: false).getGroups;
      });
    });
  }

  /// saves the order locally and performs changes.
  /// Closes this page on success.
  void saveOrder() {
    global.localData.updateGroupOrder(groups.map((e) => e.groupId).toList()).then((value) {
      Provider.of<ClusterNotifier>(context, listen: false).addGroups(groups);
      Navigator.pop(context);
    });
  }

  /// Drag and drop changes th order in the groups list.
  void onReorder (int start, int current) {
    // dragging from top to bottom
    if (start < current) {
      int end = current - 1;
      Group startItem = groups[start];
      int i = 0;
      int local = start;
      do {
        groups[local] = groups[++local];
        i++;
      } while (i < end - start);
      groups[end] = startItem;
    }
    // dragging from bottom to top
    else if (start > current) {
      Group startItem = groups[start];
      for (int i = start; i > current; i--) {
        groups[i] = groups[i - 1];
      }
      groups[current] = startItem;
    }
    setState(() {});
  }

}