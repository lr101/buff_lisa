
import 'package:buff_lisa/10_UploadOffline/upload_offline_logic.dart';
import 'package:buff_lisa/1_BottomNavigationBar/navbar_ui.dart';
import 'package:buff_lisa/3_ScreenAddPin/camera_logic.dart';
import 'package:buff_lisa/6_Group_Search/my_groups_logic.dart';
import 'package:buff_lisa/9_Profile/profile_logic.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_groups.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../2_ScreenMaps/maps_logic.dart';
import '../5_Feed/feed_logic.dart';
import '../8_SelectGroupWidget/select_group_widget_logic.dart';
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/DTOClasses/hive_handler.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Providers/cluster_notifier.dart';


class BottomNavigationWidget extends StatefulWidget {
  const BottomNavigationWidget({Key? key}) : super(key: key);

  @override
  State<BottomNavigationWidget> createState() => BottomNavigationWidgetState();
}

class BottomNavigationWidgetState extends State<BottomNavigationWidget> {

  /// the index of the widget opened on start - [selectedIndex] = 2 opens the map page
  int selectedIndex = 2;

  /// TODO what is global key used for?
  final GlobalKey globalKey = GlobalKey(debugLabel: 'btm_app_bar');

  /// TODO what is this used for?
  late ProviderContext io = ProviderContext(globalKey, context);

  /// Controller to change shown page of navbar
  late PageController pageController;

  final Widget multiSelect = const SelectGroupWidget(multiSelector: true,);

  /// List of Widgets shown and used in the navbar
  late final List<Widget> widgetOptions = <Widget>[
    const MyGroupsPage(),
    CameraWidget(io : io),
    MapsWidget(io : io),
    const FeedPage(),
    const ProfilePage()
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
    pageController = PageController(initialPage: selectedIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getGroups();
    });
  }

  Widget getMultiSelector() {
    if (selectedIndex == 2 || selectedIndex == 3) {
      return multiSelect;
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

  /// loads all offline pins
  /// tries pushing the offline pins to server
  /// fetches all pins from server and save in provider
  /// update all points and user points via provider context
  Future<void> _getGroups() async {
    global.pinsLoaded = true;
    try {
      List<Group> groups = await FetchGroups.getUserGroups();
      await groupsOnline(groups);
    } on Exception catch (_, e) {
      print(_);
      groupsOffline();
    }

  }

  Future<void> groupsOnline(List<Group> groups) async {
    // groups are saved locally for the current session as well as offline for offline sessions
    Provider.of<ClusterNotifier>(context, listen:false).addGroups(groups);
    // load all offline pins from files
    Provider.of<ClusterNotifier>(context, listen:false).loadOfflinePins().then((value)  {
    if (mounted && value.isNotEmpty) {
        // open upload page if offline saved pins exist
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UploadOfflinePage(pins: value),
          )
        );
      }
    });
    // activate previous active groups
    final HiveHandler<int, dynamic> offlineActiveGroups = await HiveHandler.fromInit<int, dynamic>("activeGroups");
    for (int id in await offlineActiveGroups.keys()) {
      if (!mounted) return;
      Group group = Provider.of<ClusterNotifier>(context, listen:false).getGroupByGroupId(id);
      await Provider.of<ClusterNotifier>(context, listen:false).activateGroup(group); //new thread
    }



  }

  Future<void> groupsOffline() async {
    // show error message
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot connect to server, offline groups are displayed"))
    );
    Provider.of<ClusterNotifier>(context, listen:false).offline = true;
    // load previous offline saved groups
    await Provider.of<ClusterNotifier>(context, listen:false).loadOfflineGroups();
    if (!mounted) return;
    List<Pin> pins = await Provider.of<ClusterNotifier>(context, listen:false).loadOfflinePins();
    if (!mounted) return;
    for (Pin pin in pins) {
      await Provider.of<ClusterNotifier>(context, listen:false).addPin(pin);
    }

  }

}
