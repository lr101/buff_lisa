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
  static const _pageSize = 2;
  
  final PagingController<int, Widget> pagingController = PagingController(firstPageKey: 0, invisibleItemsThreshold: 1);
  late Set<Group> groups = {};
  late Map<Pin, Uint8List?> allWidgets = {};

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
      List<Widget> newItems = [];
      List<Group> g = [];
      for (int i = 0; i < _pageSize && i + pageKey < allWidgets.keys.length; i++) {
        Pin key =  allWidgets.keys.elementAt(pageKey + i);
        Uint8List? value = allWidgets.values.elementAt(pageKey + i);
        if (value != null) {
          Widget w = FeedCard(pin: key, image: value,);
          if (key.group.active) newItems.add(w);
        } else {
          Uint8List image = await ClusterNotifier.getPinImage(key);
          allWidgets[key] = image;
          Widget w = FeedCard(pin: key, image: image,);
          if (key.group.active) newItems.add(w);
        }
        g.add(key.group);
      }
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      pagingController.error = error;
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
            for (Pin pin in group.pins) {
              allWidgets[pin] = null;
            }
          }
        }
      }
      allWidgets = SplayTreeMap<Pin, Uint8List?>.from(allWidgets, (k1, k2) => k1.creationDate.compareTo(k2.creationDate) * -1);
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