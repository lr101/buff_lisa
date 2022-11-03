
import 'dart:convert';
import 'package:buff_lisa/1_BottomNavigationBar/navbar_ui.dart';
import 'package:buff_lisa/3_ScreenAddPin/camera_logic.dart';
import 'package:buff_lisa/6_Shop/shop_logic.dart';
import 'package:buff_lisa/7_Settings/settings_logic.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../2_ScreenMaps/maps_logic.dart';
import '../5_Ranking/ranking_logic.dart';
import '../Files/pin.dart';
import '../Files/provider_context.dart';
import '../Files/global.dart' as global;
import '../Files/restAPI.dart';
import '../Providers/cluster_notifier.dart';
import '../Providers/points_notifier.dart';


class BottomNavigationWidget extends StatefulWidget {
  const BottomNavigationWidget({Key? key}) : super(key: key);

  @override
  State<BottomNavigationWidget> createState() => BottomNavigationWidgetState();
}

class BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  int selectedIndex = 0;
  final GlobalKey globalKey = GlobalKey(debugLabel: 'btm_app_bar');
  late ProviderContext io = ProviderContext(globalKey, context);
  late PageController pageController;

  late final List<Widget> widgetOptions = <Widget>[
    MapsWidget(io : io),
    CameraWidget(io : io),
    const RankingPage(),
    ShopPage(),
    const Settings()
  ];

  @override
  Widget build(BuildContext context) => NavBarUI(state: this);


  /// initializes pageController for the navbar and calls async for all pins from server
  @override
  void initState() {
    super.initState();
    if (!global.pinsLoaded) {
      _getPins();
    }
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
  Future<void> _getPins() async {
    global.pinsLoaded = true;
    await Provider.of<ClusterNotifier>(context, listen:false).loadOfflinePins();
    await _tryOfflinePins();
    RestAPI.fetchAllPins().then((pins) async {
      await Provider.of<ClusterNotifier>(context, listen:false).addPins(pins);
      _updateUserPoints();
    });


  }

  /// update user points by saving values in provider
  void _updateUserPoints() {
    List<Pin> pins = List.from(Provider.of<ClusterNotifier>(context, listen:false).getAllPins());
    List<Mona> monas = List.from(Provider.of<ClusterNotifier>(context, listen:false).getOfflinePins());
    Provider.of<PointsNotifier>(context, listen: false).setNumAll(pins.length + monas.length);
    for (Pin pin in pins) {
      if (pin.username == global.username) {
        Provider.of<PointsNotifier>(context, listen: false).incrementPoints();
      }
    }
  }


  /// load offline pins and try pushing to server
  Future<void> _tryOfflinePins() async {
    List<Mona> monas = List.from(Provider.of<ClusterNotifier>(context, listen:false).getOfflinePins());
    for (Mona mona in monas) {
      final response = await RestAPI.postPin(mona);
      if (response.statusCode == 201 || response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(await response.transform(utf8.decoder).join()) as Map<String, dynamic>;
        Pin pin = Pin.fromJson(json);
        if (!mounted) return;
        Provider.of<ClusterNotifier>(context, listen:false).deleteOfflinePin(mona.pin.id);
        Provider.of<ClusterNotifier>(context, listen:false).addPin(pin);
      }
    }
  }

}
