import 'dart:typed_data';

import 'package:buff_lisa/9_Profile/profile_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/ServerCalls/fetch_users.dart';
import 'package:buff_lisa/Files/Widgets/custom_show_and_pick.dart';
import 'package:buff_lisa/Files/Widgets/custom_title.dart';
import 'package:buff_lisa/Providers/user_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../7_Settings/settings_logic.dart';

class ProfilePageUI extends StatefulUI<ProfilePage, ProfilePageState> {

  const ProfilePageUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: null,
          body: ListView(
            children: [
              getTitle(
                thisUserTitle: CustomTitle(
                    titleBar: CustomTitleBar(
                        title: state.widget.username,
                        back: false,
                        action: CustomAction(icon: const Icon(Icons.settings), action: () => state.handlePushPage(const Settings()),)
                    ),
                    child: CustomShowAndPick(
                      provide: () => FetchUsers.fetchProfilePicture(state.widget.username),
                      updateCallback: provideImage,
                    )
                ),
                otherUserTitle: CustomTitle(
                  titleBar: CustomTitleBar(
                    title: state.widget.username,
                    back: true
                  ),
                  imageCallback: () => FetchUsers.fetchProfilePicture(state.widget.username),
                ),
              ),
              const SizedBox(height: 100,),
              const Center(
                  child: Text("Coming Soon...") //TODO
              )
            ]
          )
    );
  }

  Widget getTitle({required Widget thisUserTitle, required Widget otherUserTitle}) {
    if (state.widget.username == global.localData.username) {
      return thisUserTitle;
    } else {
      return otherUserTitle;
    }
  }

  Future<Uint8List?> provideImage(Uint8List image, BuildContext context) async {
    Provider.of<UserNotifier>(context, listen: false).removeUser(global.localData.username);
    return FetchUsers.changeProfilePicture(global.localData.username, image);
  }
}