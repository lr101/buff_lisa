import 'package:buff_lisa/9_Profile/profile_image_logic.dart';
import 'package:buff_lisa/9_Profile/profile_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Providers/profile_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Files/Other/global.dart' as global;
import '../Files/ServerCalls/fetch_pins.dart';

class ProfilePageUI extends StatefulUI<ProfilePage, ProfilePageState> {

  const ProfilePageUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Profile of #${global.username}"),
        actions: [IconButton(onPressed: state.openSettings, icon: const Icon(Icons.settings))],
      ),
      body: FutureBuilder<List<int>>(
        future: FetchPins.fetchUserPins(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Widget> widgets = [];
            int duration = 0;
            for (int i in snapshot.requireData) {
              widgets.add(ProfileImagePage(id: i, duration: duration,));
              duration = (duration + 200) % 3000;
            }
            return GridView.count(

              crossAxisCount: 3,
              children: widgets,
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      )
    );
  }
}