import 'package:flutter/material.dart';

import '../2_ScreenMaps/maps.dart';
import '../3_ScreenAddPin/addPinScreen.dart';
import '../Files/io.dart';


class BottomNavigationWidget extends StatefulWidget {
  const BottomNavigationWidget({Key? key}) : super(key: key);

  @override
  State<BottomNavigationWidget> createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  int _selectedIndex = 0;
  final GlobalKey globalKey = GlobalKey(debugLabel: 'btm_app_bar');
  late IO io = IO(globalKey: globalKey);

  late final List<Widget> _widgetOptions = <Widget>[
    MapSample(io : io),
    AddPinScreen(io : io),
    const Text(
      'Index 0: Home',
    ),
    const Text(
      'Index 0: Home',
    ),
  ];

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        key: globalKey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Map',
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_location_alt_outlined),
            label: 'Camera',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Ranking',
            backgroundColor: Colors.purple,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
            backgroundColor: Colors.pink,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: onItemTapped,
      ),
    );
  }
}
