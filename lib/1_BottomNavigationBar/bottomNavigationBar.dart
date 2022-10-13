
import 'package:buff_lisa/3_ScreenAddPin/camera.dart';
import 'package:buff_lisa/6_Shop/shopPage.dart';
import 'package:buff_lisa/7_Settings/settings.dart';
import 'package:buff_lisa/Files/MarkerHandler.dart';
import 'package:buff_lisa/Files/pointsNotifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../2_ScreenMaps/maps.dart';
import '../5_Ranking/ranking.dart';
import '../Files/io.dart';
import '../Files/global.dart' as global;


class BottomNavigationWidget extends StatefulWidget {
  const BottomNavigationWidget({Key? key}) : super(key: key);

  @override
  State<BottomNavigationWidget> createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  int _selectedIndex = 0;
  final GlobalKey globalKey = GlobalKey(debugLabel: 'btm_app_bar');
  late IO io = IO(globalKey, MarkerHandler(), context);
  late PageController _pageController;

  late final List<Widget> _widgetOptions = <Widget>[
    MapSample(io : io),
    CameraStatefulWidget(io : io),
    RankingPage(io: io),
    ShopPage(),
    const Settings()
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(_selectedIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: _widgetOptions,
        ),
        bottomNavigationBar: SizedBox(height: 58, child:BottomNavigationBar(
          backgroundColor: Colors.white,
          unselectedIconTheme: const IconThemeData(color: global.cPrime),
          key: globalKey,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_location_alt_outlined),
              label: 'Camera',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups),
              label: 'Ranking',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Shop',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: global.cFifth,
          onTap: onItemTapped,
        )
      ),
    );
  }
}
