import 'dart:collection';

import 'package:buff_lisa/5_Feed/feed_ui.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../Ads/NativeAdFactoryFeed.dart';
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'FeedCard/feed_card_logic.dart';


class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  FeedPageState createState() => FeedPageState();
}

class FeedPageState extends State<FeedPage>  with AutomaticKeepAliveClientMixin<FeedPage>{

  /// Controller for the Paged List-view
  /// always shows first item first and loads 3 items that are out of view
  final PagingController<int, Widget> pagingController = PagingController(firstPageKey: 0, invisibleItemsThreshold: 5);

  /// Set of Groups that are currently shown
  /// Used to reduce the amounts of Widgets that need to be created everytime the Provider updates its values
  late Set<Group> groups = {};

  /// Saves all Pins that could be seen in the feed with the Widget that is shown if already created
  late List<Pin> allWidgets = [];

  final _addEvery = 4;


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
        Pin key = allWidgets.elementAt(pageKey);
        Widget widget =  FeedCard(pin: key, update: pullRefresh,);
        if (key.group.active) {
          if (allWidgets.length == pageKey + 1) {
            pagingController.appendLastPage([widget]);
          } else {
            if (pageKey % _addEvery == 0) {
              pagingController.appendPage(
                  [widget, const CustomAdWidget()], pageKey + 1);
            } else {
              pagingController.appendPage([widget], pageKey + 1);
            }
          }
        }
    } catch (error) {
      pagingController.appendLastPage([]);
    }
  }

  void init() {
    groups = Provider.of<ClusterNotifier>(context).getActiveGroups.toSet();
    pullRefresh();
  }

  void refresh() {
    groups = Provider.of<ClusterNotifier>(context, listen: false).getActiveGroups.toSet();
    pullRefresh();
  }


  Future<void> pullRefresh() async {
    allWidgets.clear();
    for (Group group in groups) {
      Set<Pin> pins = await group.pins.asyncValue();
      allWidgets.addAll(pins);
    }
    allWidgets.sort((k1, k2) => k1.creationDate.compareTo(k2.creationDate) * -1);
    pagingController.refresh();
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