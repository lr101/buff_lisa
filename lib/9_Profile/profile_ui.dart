import 'dart:typed_data';
import 'package:buff_lisa/9_Profile/profile_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_users.dart';
import 'package:buff_lisa/Files/Widgets/CustomShowAndPick.dart';
import 'package:buff_lisa/Files/Widgets/CustomTitle.dart';
import 'package:buff_lisa/Providers/user_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../7_Settings/settings_logic.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;

class ProfilePageUI extends StatefulUI<ProfilePage, ProfilePageState> {

  const ProfilePageUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: CustomTitle(
              titleBar: CustomTitleBar(
                  title: "Your Profile",
                  back: false,
                  action: CustomAction(icon: const Icon(Icons.settings), action: () => state.handlePushPage(const Settings()),)
              ),
              child: CustomShowAndPick(
                provide: () => FetchUsers.fetchProfilePicture(global.username),
                updateCallback: provideImage,
              )
          )
        )
    );
  }

  Future<Uint8List?> provideImage(Uint8List image, BuildContext context) async {
    Provider.of<UserNotifier>(context, listen: false).removeUser(global.username);
    return FetchUsers.changeProfilePicture(global.username, image);
  }
}