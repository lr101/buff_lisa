import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:flutter/material.dart';
import '../Files/global.dart' as global;
import 'navbar_logic.dart';


class NavBarUI extends StatefulUI<BottomNavigationWidget, BottomNavigationWidgetState> {

  const NavBarUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageView(
          controller: state.pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: state.widgetOptions,
        ),
        bottomNavigationBar: SizedBox(height: 58, child:BottomNavigationBar(
          backgroundColor: Colors.white,
          unselectedIconTheme: const IconThemeData(color: global.cPrime),
          key: state.globalKey,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_location_alt_outlined),
              label: 'Camera',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups),
              label: 'Feed',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: state.selectedIndex,
          selectedItemColor: global.cFifth,
          onTap: state.onItemTapped,
        )
      ),
    );
  }
}
