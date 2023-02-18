import 'package:buff_lisa/7_Settings/EditEmail/email_logic.dart';
import 'package:buff_lisa/7_Settings/ProfileSettings/profile_settings_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:flutter/material.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/Widgets/custom_title.dart';

class ProfileSettingsUI extends StatefulUI<ProfileSettings, ProfileSettingsState> {

  const ProfileSettingsUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: ListView(
        children: [
            const CustomTitle(
              titleBar: CustomTitleBar(
                title: "Profile Settings",
                back: true,
              ),
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