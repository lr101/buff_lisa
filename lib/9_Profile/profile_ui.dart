import 'package:buff_lisa/9_Profile/profile_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:flutter/material.dart';
import '../Files/Other/global.dart' as global;

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
      body: FutureBuilder<Widget>(
        future: state.getUserImages(),
        builder: (context, snapshot) {
          if (snapshot.hasData) { return snapshot.requireData;}
          else { return const CircularProgressIndicator();}
        },
      )
    );
  }
}