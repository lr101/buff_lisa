import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'navbar_logic.dart';


class NavBarUI extends StatefulUI<BottomNavigationWidget, BottomNavigationWidgetState> {

  const NavBarUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [
            state.getMultiSelector(),
            Expanded(child:
              PageView(
                controller: state.pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: state.widgetOptions,
              ),
            )
          ],
        ),
        bottomNavigationBar: SizedBox(height: 58, child:BottomNavigationBar(
          backgroundColor: Colors.white,
          unselectedIconTheme: IconThemeData(color: Provider.of<ThemeProvider>(context).getCustomTheme.c2),
          key: state.globalKey,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: 'Groups',
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
              icon: Icon(Icons.dynamic_feed),
              label: 'Feed',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: state.selectedIndex,
          selectedItemColor: Provider.of<ThemeProvider>(context).getCustomTheme.c1,
          onTap: state.onItemTapped,
        )
      ),
    );
  }


}
