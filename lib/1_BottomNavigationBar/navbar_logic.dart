
import 'package:buff_lisa/10_UploadOffline/upload_offline_logic.dart';

import 'package:buff_lisa/1_BottomNavigationBar/navbar_ui.dart';
import 'package:buff_lisa/3_ScreenAddPin/camera_logic.dart';
import 'package:buff_lisa/6_Group_Search/my_groups_logic.dart';
import 'package:buff_lisa/9_Profile/profile_logic.dart';
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/ServerCalls/fetch_groups.dart';
import 'package:buff_lisa/Files/Widgets/custom_error_message.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../2_ScreenMaps/maps_logic.dart';
import '../5_Feed/feed_logic.dart';
import '../8_SelectGroupWidget/select_group_widget_logic.dart';
import '../Files/Other/navbar_context.dart';


class BottomNavigationWidget extends StatefulWidget {
  const BottomNavigationWidget({Key? key}) : super(key: key);

  @override
  State<BottomNavigationWidget> createState() => BottomNavigationWidgetState();
}

class BottomNavigationWidgetState extends State<BottomNavigationWidget> {

  /// the index of the widget opened on start - [selectedIndex] = 2 opens the map page
  int selectedIndex = 2;

  /// key that makes it possible to identify navbar globally
  GlobalKey navBarKey = GlobalKey(debugLabel: 'btm_app_bar');

  /// makes it possible to redirect to a tab of the navigation bar
  late NavBarContext navbarContext = NavBarContext(navBarKey, context);

  /// Controller to change shown page of navbar
  late PageController pageController;

  /// selector widget for groups
  /// shown on top of screen in map and feed page
  final Widget multiSelect = const SelectGroupWidget();

  /// List of Widgets shown and used in the navbar
  late final List<Widget> widgetOptions = <Widget>[
    const MyGroupsPage(),
    CameraWidget(navbarContext : navbarContext),
    Stack(children: [const MapsWidget(), multiSelect]),
    Column(children: [multiSelect, const SizedBox(height: 10,), const Expanded(child: FeedPage())]),
    ProfilePage( username: global.localData.username,)
  ];

  @override
  Widget build(BuildContext context) => NavBarUI(state: this);

  /// initializes pageController for the navbar and calls async for all pins from server
  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: selectedIndex);
  }

  /// returns the multi selector widget for map and feed page
  Widget getMultiSelector() {
    if (selectedIndex == 2 || selectedIndex == 3) {
      return Align(alignment: AlignmentDirectional.topCenter, child: multiSelect);
    } else {
      return const SizedBox.shrink();
    }
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

}
