import 'package:buff_lisa/7_Settings/settings_logic.dart';
import 'package:buff_lisa/9_Profile/profile_ui.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_pins.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {

  @override
  Widget build(BuildContext context) => ProfilePageUI(state: this);

  Future<Widget> getUserImages() async {
    List<Pin> pins = await FetchPins.fetchUserPins();
    print(pins.length);
    List<Widget> children = pins.map((e) => Image.memory(e.image!)).toList();
    return GridView.count(
      crossAxisCount: 3,
      children: children,
    );
  }

  void openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Settings()),
    );
  }

}