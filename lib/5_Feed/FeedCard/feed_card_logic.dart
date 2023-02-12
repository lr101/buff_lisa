import 'package:buff_lisa/5_Feed/FeedCard/feed_card_ui.dart';
import 'package:buff_lisa/Files/DTOClasses/hive_handler.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../7_Settings/Report/report_user.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;

class FeedCard extends StatefulWidget {
  const FeedCard({super.key, required this.pin, this.update});

  /// Pin shown on this Card shown in the feed
  final Pin pin;



  final Future<void> Function()? update;

  @override
  FeedCardState createState() => FeedCardState();
}

class FeedCardState extends State<FeedCard>   with AutomaticKeepAliveClientMixin<FeedCard>{

  late final LatLng center;

  /// controller of the flutter_map
  MapController controller = MapController();

  double currentZoom = global.feedZoom;

  @override
  void initState() {
    super.initState();
    center = LatLng(widget.pin.latitude, widget.pin.longitude);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FeedCardUI(state: this);
  }

  Future<void> handleHidePost(BuildContext context) async {
    if (global.username != widget.pin.username) {
      HiveHandler<int, DateTime> hiddenPosts = await HiveHandler.fromInit<int, DateTime>(global.hiddenPosts);
      await hiddenPosts.put(DateTime.now(), key: widget.pin.id);
      if (!mounted) return;
      await Provider.of<ClusterNotifier>(context, listen: false).hidePin(widget.pin);
      widget.update!();
    }
  }

  Future<void> handleHideUsers(BuildContext context) async {
    if (global.username != widget.pin.username) {
      HiveHandler<String, DateTime> hiddenUsers = await HiveHandler.fromInit<String, DateTime>(global.hiddenUsers);
      await hiddenUsers.put(DateTime.now(), key: widget.pin.username);
      if (!mounted) return;
      await Provider.of<ClusterNotifier>(context, listen: false).updateFilter();
      widget.update!();
    }
  }

  Future<void> handleReportUser(BuildContext context) async {
    String username = widget.pin.username;
    if (username != global.username) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ReportUser(content: username, title: "Report User", hintText: "Why do you want to report $username?", userText:  'Report user: $username')),
      );
    }
  }

  Future<void> handleReportPost(BuildContext context) async {
    String username = widget.pin.username;
    if (username != global.username) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ReportUser(content: widget.pin.id.toString(), title: "Report Content", hintText: "Why do you want to report this content?",userText: "Report content of user: $username",)),
      );
    }
  }

  void zoomOut() {
    currentZoom -= 1;
    controller.move(center, currentZoom);
  }

  void zoomIn() {
    currentZoom += 1;
    controller.move(center, currentZoom);
  }

  /// keeps the Widget alive (keep toggle state) in the list view
  @override
  bool get wantKeepAlive => true;

}