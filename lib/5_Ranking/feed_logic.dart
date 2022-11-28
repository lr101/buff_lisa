import 'dart:collection';

import 'package:buff_lisa/5_Ranking/feed_ui.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:flutter/material.dart';
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

  /// Controller for the Paged List-view
  /// always shows first item first and loads 3 items that are out of view
  final PagingController<int, Widget> pagingController = PagingController(firstPageKey: 0, invisibleItemsThreshold: 3);

  /// Set of Groups that are currently shown
  /// Used to reduce the amounts of Widgets that need to be created everytime the Provider updates its values
  late Set<Group> groups = {};

  /// Saves all Pins that could be seen in the feed with the Widget that is shown if already created
  late Map<Pin, Widget?> allWidgets = {};

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FeedUI(state: this);
  }

  /// Inits the pagingController and adds the methods to its scroll listener
  @override
  void initState() {
    pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  /// Adds a new Feed Widget to the Listview by appending it to the pagingController
  /// Checks if the Pin at the position [pageKey] already has an existing Widget
  /// If not a new one is created
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
      pagingController.appendLastPage([]);
    }
  }

  /// Loads and reloads the pins of active groups shown on the Feed
  /// If the Provider updates the method checks if an active Group was removed or added
  /// If an active Group was removed all the pins of this group are removed from the feed
  /// If an active Group was added the pins of this group are added to the Sorted Tree [allWidgets] and sorted again by creationDate
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
        allWidgets = SplayTreeMap<Pin, Widget?>.from(allWidgets, (k1, k2) => k1.creationDate.compareTo(k2.creationDate) * -1);
      }
      pagingController.refresh();
    }

  }

  /// disposed the controller when the page is closed
  @override
  void dispose() {
    pagingController.dispose();
    super.dispose();
  }

  /// keeps Widget alive when changing tabs in navbar
  @override
  bool get wantKeepAlive => true;
}