import 'package:buff_lisa/7_Settings/email_logic.dart';
import 'package:buff_lisa/7_Settings/profile_settings_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:flutter/material.dart';
import '../Files/Other/global.dart' as global;
import '../Files/Widgets/CustomTitle.dart';

class ProfileSettingsUI extends StatefulUI<ProfileSettings, ProfileSettingsState> {

  const ProfileSettingsUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: ListView(
        children: [
            const CustomTitle(
            title: "Profile Settings",
              back: true,
            ),
            Card(
              child: TextButton(
                onPressed: () => state.handlePasswordPress(context),
                child: const Text("Change Password", ),
              ),
            ),
            Card(
              child: TextButton(
                onPressed: () => state.handleEmailPress(context),
                child: const Text("Change email", ),
              ),
            ),
            Card(
              child: TextButton(
                onPressed: () => state.handleLogoutPress(context),
                child: const Text("Logout", ),
              ),
            ),
        ],
      )
    );
  }
}