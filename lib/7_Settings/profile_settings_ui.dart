import 'package:buff_lisa/7_Settings/email_logic.dart';
import 'package:buff_lisa/7_Settings/profile_settings_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:flutter/material.dart';
import '../Files/Other/global.dart' as global;

class ProfileSettingsUI extends StatefulUI<ProfileSettings, ProfileSettingsState> {

  const ProfileSettingsUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: ListView(
        children: [
            SizedBox(
              height: 200,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
                      ],
                    ),
                    const SizedBox(height: 18,),
                    const Text("Profile Settings", style: TextStyle(fontSize: 20),)
                  ]
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