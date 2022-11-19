import 'dart:typed_data';

import 'package:buff_lisa/5_Ranking/feed_card_logic.dart';
import 'package:buff_lisa/5_Ranking/feed_ui.dart';
import 'package:buff_lisa/Files/restAPI.dart';
import 'package:flutter/material.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import '../Files/DTOClasses/group.dart';
import '../Files/DTOClasses/mona.dart';
import '../Files/global.dart' as global;
import '../Files/DTOClasses/ranking.dart';
import '../Providers/cluster_notifier.dart';
import '../Providers/feed_notifier.dart';


class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  FeedPageState createState() => FeedPageState();
}

class FeedPageState extends State<FeedPage>{
  static const _pageSize = 2;

  final PagingController<int, Pin> pagingController = PagingController(firstPageKey: 0);
  late List<Pin> sortedPins = [];
  late List<Widget> widgets = [];

  @override
  Widget build(BuildContext context) => FeedUI(state: this);

  @override
  void initState() {
    pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      List<Pin> newItems = [];
      print(pageKey);
      print(sortedPins.length);
      print("TEST--------------");
      for (int i = 0; i < _pageSize && i + pageKey < sortedPins.length; i++) {
        newItems.add(sortedPins[i + pageKey]);
      }
      print(newItems.length);
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
    sortedPins.clear();
    widgets.clear();
    for (Group group in activeGroups) {
      sortedPins.addAll(group.pins);
    }
    sortedPins.sort((p1, p2) => -(p1.creationDate.compareTo(p2.creationDate)));
    for (Pin pin in sortedPins) {
      widgets.add(FeedCard(pin: pin));
    }
    pagingController.refresh();
  }

  @override
  void dispose() {
    pagingController.dispose();
    super.dispose();
  }
}