import 'package:buff_lisa/1_BottomNavigationBar/loading_notifier.dart';
import 'package:buff_lisa/1_BottomNavigationBar/splash_loading.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Files/Themes/custom_theme.dart';
import 'navbar_logic.dart';


class NavBarUI extends StatefulUI<BottomNavigationWidget, BottomNavigationWidgetState> {

  const NavBarUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: null,
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
        bottomNavigationBar: BottomNavigationBar(
          unselectedIconTheme: IconThemeData(color:  CustomTheme.c1,),
          key: state.navBarKey,
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
          selectedItemColor: CustomTheme.c1,
          onTap: state.onItemTapped,
        )
    );
  }


}
