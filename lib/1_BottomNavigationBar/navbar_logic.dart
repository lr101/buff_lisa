
import 'dart:convert';
import 'package:buff_lisa/1_BottomNavigationBar/navbar_ui.dart';
import 'package:buff_lisa/3_ScreenAddPin/camera_logic.dart';
import 'package:buff_lisa/6_Group_Search/my_groups_logic.dart';
import 'package:buff_lisa/6_Group_Search/search_logic.dart';
import 'package:buff_lisa/7_Settings/settings_logic.dart';
import 'package:buff_lisa/Files/fetch_groups.dart';
import 'package:buff_lisa/Files/fetch_pins.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../2_ScreenMaps/maps_logic.dart';
import '../5_Ranking/feed_logic.dart';
import '../Files/DTOClasses/pin.dart';
import '../Files/provider_context.dart';
import '../Files/global.dart' as global;
import '../Files/restAPI.dart';
import '../Providers/cluster_notifier.dart';


class BottomNavigationWidget extends StatefulWidget {
  const BottomNavigationWidget({Key? key}) : super(key: key);

  @override
  State<BottomNavigationWidget> createState() => BottomNavigationWidgetState();
}

class BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  int selectedIndex = 2;
  final GlobalKey globalKey = GlobalKey(debugLabel: 'btm_app_bar');
  late ProviderContext io = ProviderContext(globalKey, context);
  late PageController pageController;

  late final List<Widget> widgetOptions = <Widget>[
    const MyGroupsPage(),
    CameraWidget(io : io),
    MapsWidget(io : io),
    const FeedPage(),
    const Settings()
  ];

  @override
  Widget build(BuildContext context) => NavBarUI(state: this);


  /// initializes pageController for the navbar and calls async for all pins from server
  @override
  void initState() {
    super.initState();
    if (global.pinsLoaded) {
      Provider.of<ClusterNotifier>(context, listen:false).clearAll();
    }
    _getGroups();
    pageController = PageController(initialPage: selectedIndex);
  }

  /// disposes pageController
  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  /// changes the index of the selected navbar page and opens the selected page
  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
      pageController.jumpToPage(selectedIndex);
    });
  }

  /// loads all offline pins
  /// tries pushing the offline pins to server
  /// fetches all pins from server and save in provider
  /// update all points and user points via provider context
  Future<void> _getGroups() async {
    global.pinsLoaded = true;

    FetchGroups.getUserGroups().then((groups) async {
      Provider.of<ClusterNotifier>(context, listen:false).addGroups(groups);
      List<Pin> pins = await Provider.of<ClusterNotifier>(context, listen:false).loadOfflinePins();
      await _tryOfflinePins(pins);
      //TODO load saved selected groups
    });

  }


  /// load offline pins and try pushing to server
  Future<void> _tryOfflinePins(List<Pin> pins) async {
    for (Pin mona in pins) {
      try {
        Pin newPin = await FetchPins.postPin(mona);
        if (!mounted) return;
        Provider.of<ClusterNotifier>(context, listen: false).deleteOfflinePinAndAddToOnline(newPin, mona);
      } catch (e) {
        Provider.of<ClusterNotifier>(context, listen: false).addOfflinePin(
            mona);
      }
    }
  }


}