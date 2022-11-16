import 'dart:typed_data';

import 'package:buff_lisa/5_Ranking/feed_ui.dart';
import 'package:buff_lisa/Files/restAPI.dart';
import 'package:flutter/material.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  late ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final state = this;
    return ChangeNotifierProvider<FeedNotifier>(
        create: (_) {
          return FeedNotifier();
        },
        builder: ((context, child) => FeedUI(state: state))
    );
  }

  ///
  @override
  void initState() {
    super.initState();

  }

  void init(BuildContext context) {
    controller =ScrollController()..addListener(() => _scrollListener(context));
    Set<Group> groups = Provider.of<ClusterNotifier>(context).getActiveGroups;
    Provider.of<FeedNotifier>(context, listen: false).initSortedPins(groups);
  }



  void _scrollListener(BuildContext context) {
    double width = (MediaQuery.of(context).size.width);
    double height2 = (MediaQuery.of(context).size.height);
    double scroll = (controller.position.maxScrollExtent) - controller.position.extentAfter +height2;
    double height = (width+38.5).toDouble();
    Provider.of<FeedNotifier>(context, listen: false).scrollFeed(scroll, height);
  }
}