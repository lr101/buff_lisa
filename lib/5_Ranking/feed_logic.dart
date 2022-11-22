import 'dart:collection';
import 'dart:typed_data';
import 'package:buff_lisa/5_Ranking/feed_ui.dart';
import 'package:buff_lisa/Files/restAPI.dart';
import 'package:flutter/material.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import '../Files/DTOClasses/group.dart';
import '../Providers/cluster_notifier.dart';
import 'feed_card_logic.dart';


class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  FeedPageState createState() => FeedPageState();
}

class FeedPageState extends State<FeedPage>  with AutomaticKeepAliveClientMixin<FeedPage>{
  static const _pageSize = 1;
  
  final PagingController<int, Widget> pagingController = PagingController(firstPageKey: 0, invisibleItemsThreshold: 3);
  late Set<Group> groups = {};
  late Map<Pin, Widget?> allWidgets = {};

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FeedUI(state: this);
  }

  @override
  void initState() {
    pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
        Pin key = allWidgets.keys.elementAt(pageKey);
        Widget? value = allWidgets.values.elementAt(pageKey);
        if (value != null && key.group.active) {
          allWidgets[key] = value;
        } else if (key.group.active) {
          allWidgets[key] = FeedCard(pin: key,);
        }
        if (allWidgets[key] != null) {
          if (allWidgets.length == pageKey + 1) {
            pagingController.appendLastPage([allWidgets[key]!]);
          } else {
            pagingController.appendPage([allWidgets[key]!], pageKey + 1);
          }
        }
    } catch (error) {
      pagingController.appendLastPage([Text("t")]);
    }
  }

  void initSortedPins() {
    final activeGroups = Provider.of<ClusterNotifier>(context).getActiveGroups.toSet();
    if (activeGroups.length != groups.length) {
      if (activeGroups.length < groups.length) {
        allWidgets.removeWhere((key, value) => !activeGroups.any((group) => group == key.group));
        groups = groups.intersection(activeGroups);
      } else if (activeGroups.length > groups.length) {
        Set<Group> oldGroups = Set.from(groups);
        groups = groups.union(activeGroups);
        for (Group group in groups) {
          if (!oldGroups.contains(group)) {
            for (Pin pin in group.getSyncPins()) {
              allWidgets[pin] = null;
            }
          }
        }
      }
      allWidgets = SplayTreeMap<Pin, Widget?>.from(allWidgets, (k1, k2) => k1.creationDate.compareTo(k2.creationDate) * -1);
      pagingController.refresh();
    }

  }

  @override
  void dispose() {
    pagingController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}