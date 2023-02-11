import 'dart:math';

import 'package:buff_lisa/7_Settings/EditEmail/email_ui.dart';
import 'package:buff_lisa/7_Settings/EditPassword/password_logic.dart';
import 'package:buff_lisa/7_Settings/ProfileSettings/profile_settings_ui.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_users.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../0_ScreenSignIn/login_logic.dart';
import '../../0_ScreenSignIn/secure.dart';
import 'package:buff_lisa/Files/DTOClasses/group_repo.dart';
import 'package:buff_lisa/Files/DTOClasses/hive_handler.dart';
import 'package:buff_lisa/Files/DTOClasses/pin_repo.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import '../EditEmail/email_logic.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<StatefulWidget> createState() => ProfileSettingsState();


}

class ProfileSettingsState extends State<ProfileSettings> {

  @override
  Widget build(BuildContext context) => ProfileSettingsUI(state: this);

  /// on password button press the password widget page is opened
  void handlePasswordPress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Password()),
    );
  }

  /// on email button press the email widget page is opened
  void handleEmailPress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Email()),
    );
  }

  /// on logout button press all existing open pages are closed and the token and username or removed
  /// the login screen widget page is opened
  Future<void> handleLogoutPress(BuildContext context) async {
    global.token = "";
    Secure.removeSecure("auth");
    global.username = "";
    Secure.removeSecure("username");
    final HiveHandler<int, dynamic> offlineActiveGroups = await HiveHandler.fromInit<int, dynamic>("activeGroups");
    await offlineActiveGroups.clear();
    HiveHandler<String, DateTime> hiddenUsers = await HiveHandler.fromInit<String, DateTime>(global.hiddenUsers);
    await hiddenUsers.clear();
    HiveHandler<int, DateTime> hiddenPosts = await HiveHandler.fromInit<int, DateTime>(global.hiddenPosts);
    await hiddenPosts.clear();
    GroupRepo repo = GroupRepo();
    await repo.init(global.groupFileName);
    await repo.clear();
    PinRepo pinRepo = PinRepo();
    await pinRepo.init(global.fileName);
    await pinRepo.deleteAll();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => const LoginScreen()
        ),
        ModalRoute.withName("/login")
    );

  }

}